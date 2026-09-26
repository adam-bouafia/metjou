import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

/// Four digit PIN field used to stop an SOS alert and to change the PIN.
Widget pinInput({
  required TextEditingController controller,
  required FocusNode focusNode,
  required ValueChanged<String> onCompleted,
}) {
  return Builder(
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      final base = PinTheme(
        width: 56,
        height: 56,
        textStyle: TextStyle(fontSize: 20, color: scheme.onSurface),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
      );
      return Pinput(
        length: 4,
        controller: controller,
        focusNode: focusNode,
        obscureText: true,
        onCompleted: onCompleted,
        defaultPinTheme: base,
        focusedPinTheme: base.copyDecorationWith(
          border: Border.all(color: scheme.primary, width: 2),
        ),
        submittedPinTheme: base.copyDecorationWith(
          border: Border.all(color: scheme.primary),
        ),
      );
    },
  );
}
