import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metjou/core/theme/app_theme.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metjou/features/home/presentation/home.dart';
import 'package:metjou/core/widgets/glass.dart';
import 'package:metjou/features/home/presentation/widgets/glass_dock.dart';
import 'package:metjou/features/home/presentation/widgets/sos_button.dart';
import 'package:metjou/features/contacts/presentation/contacts_viewmodel.dart';
import 'package:metjou/features/contacts/presentation/my_contacts.dart';
import 'package:metjou/features/home/presentation/sos_viewmodel.dart';
import 'package:metjou/core/services/alert_countdown.dart';
import 'package:metjou/core/widgets/pin_input.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key, this.pageIndex = 0});

  final int pageIndex;

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard>
    with WidgetsBindingObserver {
  late int currentPage = widget.pageIndex;
  int? _pin;

  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadPin();
    WidgetsBinding.instance.addObserver(this);
    AlertCountdown.remaining.addListener(_onCountdown);
    checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AlertCountdown.remaining.removeListener(_onCountdown);
    _pinPutController.dispose();
    _pinPutFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _pin = prefs.getInt('pin'));
  }

  /// An alert can also be sent by shaking, the Quick Settings tile, the
  /// widget or a shortcut; re-read the state when the app comes back and
  /// when a countdown ends, so the SOS button shows STOP.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(sosViewModelProvider.notifier).refresh();
    }
  }

  void _onCountdown() {
    if (AlertCountdown.remaining.value == null) {
      Future.delayed(
        const Duration(seconds: 3),
        () => ref.read(sosViewModelProvider.notifier).refresh(),
      );
    }
  }

  Future<void> sendAlertSMS(bool isAlert) async {
    final l10n = context.l10n;
    if (!isAlert) Fluttertoast.showToast(msg: l10n.notifyingSafe);
    final sent = await ref
        .read(sosViewModelProvider.notifier)
        .setAlert(
          isAlert,
          isAlert ? l10n.smsSos : l10n.smsSafe,
          withLocation: isAlert,
        );
    if (sent == 0) {
      Fluttertoast.showToast(
        msg: l10n.noContactsFound,
        backgroundColor: Latte.red,
      );
    } else if (isAlert) {
      Fluttertoast.showToast(msg: l10n.alertSent, backgroundColor: Latte.green);
    }
  }

  /// Asks once for everything the alert path needs. Background location has
  /// to be requested after foreground location on Android 11+.
  Future<void> checkPermission() async {
    await [
      Permission.location,
      Permission.sms,
      Permission.phone,
      Permission.microphone,
      Permission.notification,
    ].request();
    if (await Permission.location.isGranted) {
      await Permission.locationAlways.request();
    }
  }

  void showPinModelBottomSheet(int userPin) {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height / 2.7,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: Divider(indent: 20, endIndent: 20)),
                  Text(
                    context.l10n.enterPin,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Expanded(child: Divider(indent: 20, endIndent: 20)),
                ],
              ),
              Icon(
                Icons.password,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              Container(
                margin: const EdgeInsets.all(20.0),
                padding: const EdgeInsets.all(20.0),
                child: pinInput(
                  controller: _pinPutController,
                  focusNode: _pinPutFocusNode,
                  onCompleted: (pin) => _showSnackBar(pin, context, userPin),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String pin, BuildContext context, int userPin) {
    if (userPin == int.parse(pin)) {
      Fluttertoast.showToast(msg: context.l10n.gladYouAreSafe);
      sendAlertSMS(false);
      _pinPutController.clear();
      _pinPutFocusNode.unfocus();
      Navigator.pop(context);
    } else {
      _pinPutController.clear();
      Fluttertoast.showToast(msg: context.l10n.wrongPin);
    }
  }

  Future<void> _onSosPressed(bool alerted) async {
    if (!alerted) {
      sendAlertSMS(true);
      return;
    }
    final pin = _pin ?? -1111;
    if (pin == -1111) {
      sendAlertSMS(false);
    } else {
      showPinModelBottomSheet(pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final alerted = ref.watch(sosViewModelProvider).alerted;
    return Scaffold(
      extendBody: true,
      floatingActionButton: currentPage == 1
          ? FloatingActionButton(
              onPressed: () async {
                if (await addSosContactFlow(context)) {
                  ref.read(contactsViewModelProvider.notifier).reload();
                }
              },
              child: const Icon(Icons.person_add_alt_1),
            )
          : null,
      bottomNavigationBar: GlassDock(
        currentPage: currentPage,
        onSelect: (page) {
          if (page != currentPage) setState(() => currentPage = page);
        },
        center: SosButton(
          alerted: alerted,
          onPressed: () => _onSosPressed(alerted),
        ),
      ),
      body: GlassBackground(
        child: SafeArea(
          bottom: false,
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, primary, secondary) =>
                FadeThroughTransition(
                  animation: primary,
                  secondaryAnimation: secondary,
                  fillColor: Colors.transparent,
                  child: child,
                ),
            child: currentPage == 0
                ? const Home(key: ValueKey('home'))
                : MyContactsScreen(key: const ValueKey('contacts')),
          ),
        ),
      ),
    );
  }
}
