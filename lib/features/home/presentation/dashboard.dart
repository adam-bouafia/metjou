import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metjou/features/home/presentation/home.dart';
import 'package:metjou/features/home/presentation/widgets/glass_dock.dart';
import 'package:metjou/features/home/presentation/widgets/sos_button.dart';
import 'package:metjou/features/contacts/presentation/my_contacts.dart';
import 'package:metjou/core/services/background_services.dart';
import 'package:metjou/core/widgets/pin_input.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, this.pageIndex = 0});

  final int pageIndex;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool alerted = false;
  late int currentPage = widget.pageIndex;
  SharedPreferences? prefs;

  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    checkAlertSharedPreferences();
    checkPermission();
  }

  @override
  void dispose() {
    _pinPutController.dispose();
    _pinPutFocusNode.dispose();
    super.dispose();
  }

  Future<void> checkAlertSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        alerted = prefs!.getBool("alerted") ?? false;
      });
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

  Future<void> sendAlertSMS(bool isAlert) async {
    final l10n = context.l10n;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("alerted", isAlert);
    setState(() => alerted = isAlert);

    if (!isAlert) {
      Fluttertoast.showToast(msg: l10n.notifyingSafe);
    }
    final sent = isAlert
        ? await BackgroundServices.sendSosAlert(l10n.smsSos)
        : await BackgroundServices.sendSosAlert(
            l10n.smsSafe,
            withLocation: false,
          );

    if (sent == 0) {
      await prefs.setBool("alerted", false);
      if (mounted) setState(() => alerted = false);
      Fluttertoast.showToast(
        msg: l10n.noContactsFound,
        backgroundColor: Colors.red,
      );
    } else if (isAlert) {
      Fluttertoast.showToast(
        msg: l10n.alertSent,
        backgroundColor: Colors.green,
      );
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
              Image.asset("assets/pin.webp"),
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

  Future<void> _onSosPressed() async {
    if (!alerted) {
      sendAlertSMS(true);
      return;
    }
    final pin = prefs?.getInt('pin') ?? -1111;
    if (pin == -1111) {
      sendAlertSMS(false);
    } else {
      showPinModelBottomSheet(pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: currentPage == 1
          ? FloatingActionButton(
              onPressed: () async {
                if (await pickSosContact(context)) setState(() {});
              },
              child: const Icon(Icons.person_add_alt_1),
            )
          : null,
      bottomNavigationBar: GlassDock(
        currentPage: currentPage,
        onSelect: (page) {
          if (page != currentPage) setState(() => currentPage = page);
        },
        center: SosButton(alerted: alerted, onPressed: _onSosPressed),
      ),
      body: SafeArea(
        bottom: false,
        child: currentPage == 0 ? Home() : MyContactsScreen(),
      ),
    );
  }
}
