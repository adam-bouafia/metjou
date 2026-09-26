import 'package:flutter/material.dart';
import 'package:metjou/utility/app_locale.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metjou/dashboard/home.dart';
import 'package:metjou/dashboard/contact_screens/my_contacts.dart';
import 'package:metjou/utility/background_services.dart';
import 'package:metjou/utility/pin_input.dart';

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
        : await BackgroundServices.sendSosAlert(l10n.smsSafe, withLocation: false);

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

  showPinModelBottomSheet(int userPin) {
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
              color: Colors.white,
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
                    Expanded(
                      child: Divider(
                        indent: 20,
                        endIndent: 20,
                      ),
                    ),
                    Text(
                      context.l10n.enterPin,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Expanded(
                      child: Divider(
                        indent: 20,
                        endIndent: 20,
                      ),
                    ),
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
        });
  }

  void _showSnackBar(String pin, BuildContext context, int userPin) {
    if (userPin == int.parse(pin)) {
      Fluttertoast.showToast(
        msg: context.l10n.gladYouAreSafe,
      );
      sendAlertSMS(false);
      _pinPutController.clear();
      _pinPutFocusNode.unfocus();
      Navigator.pop(context);
    } else {
      _pinPutController.clear();
      Fluttertoast.showToast(
        msg: context.l10n.wrongPin,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFCFE),
      floatingActionButton: currentPage == 1
          ? FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async {
                if (await pickSosContact(context)) setState(() {});
              },
              child: Image.asset(
                "assets/add-contact.webp",
                height: 60,
              ),
            )
          : FloatingActionButton(
              backgroundColor: Color(0xFFFB9580),
              onPressed: () async {
                if (alerted) {
                  int pin = (prefs?.getInt('pin') ?? -1111);
                  if (pin == -1111) {
                    sendAlertSMS(false);
                  } else {
                    showPinModelBottomSheet(pin);
                  }
                } else {
                  sendAlertSMS(true);
                }
              },
              child: alerted
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/alarm.webp",
                          height: 24,
                        ),
                        Text(context.l10n.stop)
                      ],
                    )
                  : Image.asset(
                      "assets/icons/alert.webp",
                      height: 36,
                    ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 12,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                  onTap: () {
                    if (currentPage != 0)
                      setState(() {
                        currentPage = 0;
                      });
                  },
                  child: Image.asset(
                    "assets/home.webp",
                    height: 40,
                  )),
              InkWell(
                  onTap: () {
                    if (currentPage != 1)
                      setState(() {
                        currentPage = 1;
                      });
                  },
                  child: Image.asset("assets/phone_red.webp", height: 40)),
            ],
          ),
        ),
      ),
      body: SafeArea(child: currentPage == 0 ? Home() : MyContactsScreen()),
    );
  }
}
