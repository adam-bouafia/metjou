import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/features/fake_call/data/fake_call_service.dart';

const _delays = [
  Duration.zero,
  Duration(seconds: 10),
  Duration(seconds: 30),
  Duration(minutes: 1),
  Duration(minutes: 5),
];

/// Choose who "calls" and when it rings.
Future<void> showFakeCallSheet(BuildContext context) async {
  final name = await FakeCallService.callerName();
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FakeCallSheet(initialName: name),
  );
}

class _FakeCallSheet extends StatefulWidget {
  const _FakeCallSheet({required this.initialName});

  final String initialName;

  @override
  State<_FakeCallSheet> createState() => _FakeCallSheetState();
}

class _FakeCallSheetState extends State<_FakeCallSheet> {
  late final _name = TextEditingController(text: widget.initialName);
  Duration _delay = const Duration(seconds: 10);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String _label(BuildContext context, Duration d) {
    final l10n = context.l10n;
    if (d == Duration.zero) return l10n.fakeCallNow;
    return d.inMinutes >= 1
        ? l10n.minutes(d.inMinutes)
        : l10n.seconds(d.inSeconds);
  }

  Future<void> _start() async {
    final name = _name.text.trim();
    if (name.isNotEmpty) await FakeCallService.setCallerName(name);
    if (!mounted) return;
    Navigator.pop(context);
    await FakeCallService.schedule(_delay);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.fakeCall, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.fakeCallCaller,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.fakeCallWhen,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final d in _delays)
                ChoiceChip(
                  label: Text(_label(context, d)),
                  selected: _delay == d,
                  onSelected: (_) => setState(() => _delay = d),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.call),
              label: Text(l10n.fakeCallStart),
            ),
          ),
        ],
      ),
    );
  }
}
