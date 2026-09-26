import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

final _pinTheme = PinTheme(
  width: 56,
  height: 56,
  textStyle: const TextStyle(fontSize: 20),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.deepPurpleAccent.withValues(alpha: .5)),
    borderRadius: BorderRadius.circular(5.0),
  ),
);

/// Four digit PIN field used to stop an SOS alert and to change the PIN.
Widget pinInput({
  required TextEditingController controller,
  required FocusNode focusNode,
  required ValueChanged<String> onCompleted,
}) {
  return Pinput(
    length: 4,
    controller: controller,
    focusNode: focusNode,
    obscureText: true,
    onCompleted: onCompleted,
    defaultPinTheme: _pinTheme,
    focusedPinTheme: _pinTheme.copyDecorationWith(
      border: Border.all(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(15.0),
    ),
    submittedPinTheme: _pinTheme.copyDecorationWith(
      border: Border.all(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(20.0),
    ),
  );
}
