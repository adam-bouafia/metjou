import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metjou/core/widgets/pin_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key, required this.pin});

  final int pin;

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  String currentPin = "";
  bool pinChanged = false;

  final TextEditingController _pinPutController1 = TextEditingController();
  final TextEditingController _pinPutController2 = TextEditingController();
  final FocusNode _pinPutFocusNode1 = FocusNode();
  final FocusNode _pinPutFocusNode2 = FocusNode();

  void changePin(int parse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("pin", parse);
  }

  void changePinSnakBar(String pin) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 10),
      content: SizedBox(
        height: 20.0,
        child: Center(
          child: Text(
            context.l10n.pinChanged,
            style: const TextStyle(fontSize: 16.0),
          ),
        ),
      ),
      backgroundColor: Colors.deepPurpleAccent,
    );
    changePin(int.parse(pin));
    setState(() {
      pinChanged = true;
    });
    _pinPutController1.clear();
    _pinPutController2.clear();
    _pinPutFocusNode1.unfocus();
    _pinPutFocusNode2.unfocus();
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showSnackBar(String pin, BuildContext context) {
    if (widget.pin != -1111) {
      if (currentPin.isEmpty || currentPin.length != 4) {
        Fluttertoast.showToast(msg: context.l10n.enterCurrentPinFirst);
        _pinPutFocusNode2.unfocus();
        return;
      }
      if (currentPin != widget.pin.toString()) {
        final snackBar = SnackBar(
          duration: const Duration(seconds: 10),
          content: SizedBox(
            height: 20.0,
            child: Center(
              child: Text(
                context.l10n.currentPinWrong,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ),
          backgroundColor: Colors.deepPurpleAccent,
        );

        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        changePinSnakBar(pin);
      }
    } else {
      changePinSnakBar(pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              widget.pin == -1111
                  ? context.l10n.createPin
                  : context.l10n.changePin,
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900),
            ),
          ),
          Center(child: Image.asset("assets/pin.webp", height: 70)),
          Visibility(
            visible: widget.pin != -1111,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 35.0, right: 20),
                  child: Row(
                    children: [
                      Text(context.l10n.currentPin),
                      Expanded(child: Divider(indent: 10, endIndent: 20)),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.all(20.0),
                  child: pinInput(
                    controller: _pinPutController1,
                    focusNode: _pinPutFocusNode1,
                    onCompleted: (String pin) {
                      currentPin = pin;
                      _pinPutFocusNode1.unfocus();
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 35.0, right: 20),
            child: Row(
              children: [
                Text(context.l10n.newPin),
                Expanded(child: Divider(indent: 10, endIndent: 20)),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            padding: const EdgeInsets.all(20.0),
            child: pinInput(
              controller: _pinPutController2,
              focusNode: _pinPutFocusNode2,
              onCompleted: (String pin) => _showSnackBar(pin, context),
            ),
          ),
          SizedBox(height: 100),
          Visibility(
            visible: pinChanged,
            child: Center(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();

                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 60,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.deepPurpleAccent,
                    ),
                    child: Center(
                      child: Text(
                        context.l10n.done,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
