import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/widgets/pin_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stored when no PIN was set.
const noPin = -1111;

/// Asks for the PIN before a protected action (opening Settings, deleting a
/// contact) so someone else cannot quietly switch features off. Returns
/// true right away when no PIN is set.
Future<bool> confirmPin(BuildContext context) async {
  final pin = (await SharedPreferences.getInstance()).getInt('pin') ?? noPin;
  if (pin == noPin || !context.mounted) return true;
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _PinSheet(pin: pin),
  );
  return ok ?? false;
}

class _PinSheet extends StatefulWidget {
  const _PinSheet({required this.pin});

  final int pin;

  @override
  State<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<_PinSheet> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _wrong = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        32 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.enterPin,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          pinInput(
            controller: _controller,
            focusNode: _focus,
            onCompleted: (value) {
              if (int.tryParse(value) == widget.pin) {
                Navigator.pop(context, true);
              } else {
                _controller.clear();
                setState(() => _wrong = true);
              }
            },
          ),
          if (_wrong) ...[
            const SizedBox(height: 12),
            Text(context.l10n.wrongPin, style: TextStyle(color: scheme.error)),
          ],
        ],
      ),
    );
  }
}
