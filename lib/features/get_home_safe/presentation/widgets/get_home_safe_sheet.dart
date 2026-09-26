import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/theme/app_theme.dart';
import 'package:metjou/features/contacts/data/sos_contacts.dart';
import 'package:metjou/features/contacts/presentation/my_contacts.dart';
import 'package:metjou/features/get_home_safe/data/get_home_safe_service.dart';

const _presetMinutes = [1, 5, 15, 30];

/// Short description of a schedule, e.g. "Every 5 min" or "At 26 Sep 23:00".
String describeSchedule(BuildContext context, GetHomeSafeSchedule schedule) {
  final l10n = context.l10n;
  return switch (schedule) {
    RepeatEvery(:final interval) => l10n.ghsEvery(interval.inMinutes),
    SendOnceAt(:final at) => l10n.ghsAt(formatDateTime(context, at)),
  };
}

String formatDateTime(BuildContext context, DateTime at) {
  final m = MaterialLocalizations.of(context);
  return "${m.formatMediumDate(at)} ${m.formatTimeOfDay(TimeOfDay.fromDateTime(at), alwaysUse24HourFormat: true)}";
}

/// Bottom sheet to choose who gets the location and when. Returns once the
/// user started or stopped Get home safe.
class GetHomeSafeSheet extends StatefulWidget {
  const GetHomeSafeSheet({super.key, required this.current});

  /// The running schedule, or null when Get home safe is off.
  final GetHomeSafeState? current;

  @override
  State<GetHomeSafeSheet> createState() => _GetHomeSafeSheetState();
}

class _GetHomeSafeSheetState extends State<GetHomeSafeSheet> {
  List<SosContact> _contacts = [];
  String? _contact;
  bool _repeat = true;
  int _minutes = 15;
  DateTime? _at;

  bool get _active => widget.current != null;

  @override
  void initState() {
    super.initState();
    final current = widget.current;
    if (current != null) {
      _contact = current.contact;
      switch (current.schedule) {
        case RepeatEvery(:final interval):
          _minutes = interval.inMinutes;
        case SendOnceAt(:final at):
          _repeat = false;
          _at = at;
      }
    }
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await loadSosContacts();
    if (mounted) setState(() => _contacts = contacts);
  }

  Future<void> _pickCustomMinutes() async {
    final controller = TextEditingController(text: "$_minutes");
    final minutes = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.ghsCustomTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: "min"),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
            child: Text(context.l10n.done),
          ),
        ],
      ),
    );
    if (minutes != null && minutes >= 1) setState(() => _minutes = minutes);
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initial = _at ?? now.add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    setState(
      () => _at = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _startOrStop() async {
    final l10n = context.l10n;
    if (_active) {
      await GetHomeSafeService.stop();
      Fluttertoast.showToast(msg: l10n.getHomeSafeOff);
    } else {
      final contact = _contact;
      if (contact == null) {
        Fluttertoast.showToast(msg: l10n.selectContactFirst);
        return;
      }
      final GetHomeSafeSchedule schedule;
      if (_repeat) {
        schedule = RepeatEvery(Duration(minutes: _minutes));
      } else {
        final at = _at;
        if (at == null || !at.isAfter(DateTime.now())) {
          Fluttertoast.showToast(msg: l10n.ghsTimeInPast);
          return;
        }
        schedule = SendOnceAt(at);
      }
      await GetHomeSafeService.start(contact, schedule);
      Fluttertoast.showToast(msg: l10n.getHomeSafeOn);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                l10n.getHomeSafe,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.ghsChooseContact, style: theme.textTheme.titleSmall),
            if (_contacts.isEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.noContacts),
                subtitle: Text(l10n.addContactHint),
                trailing: const Icon(Icons.person_add_alt),
                onTap: () async {
                  await pickSosContact(context);
                  _loadContacts();
                },
              )
            else
              RadioGroup<String>(
                groupValue: _contact,
                onChanged: (value) {
                  if (!_active) setState(() => _contact = value);
                },
                child: Column(
                  children: [
                    for (final c in _contacts)
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        value: c.phone,
                        enabled: !_active,
                        title: Text(c.name),
                        subtitle: Text(c.phone),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.repeat),
                  label: Text(l10n.ghsRepeat),
                ),
                ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.schedule),
                  label: Text(l10n.ghsOnce),
                ),
              ],
              selected: {_repeat},
              onSelectionChanged: _active
                  ? null
                  : (s) => setState(() => _repeat = s.first),
            ),
            const SizedBox(height: 12),
            if (_repeat) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in _presetMinutes)
                    ChoiceChip(
                      label: Text(l10n.ghsEvery(m)),
                      selected: _minutes == m,
                      onSelected: _active
                          ? null
                          : (_) => setState(() => _minutes = m),
                    ),
                  ChoiceChip(
                    label: Text(
                      _presetMinutes.contains(_minutes)
                          ? l10n.ghsCustom
                          : l10n.ghsEvery(_minutes),
                    ),
                    selected: !_presetMinutes.contains(_minutes),
                    onSelected: _active ? null : (_) => _pickCustomMinutes(),
                  ),
                ],
              ),
              if (_minutes == 1) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.ghsEveryMinuteWarning,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Latte.peach,
                  ),
                ),
              ],
            ] else
              OutlinedButton.icon(
                onPressed: _active ? null : _pickDateTime,
                icon: const Icon(Icons.event),
                label: Text(
                  _at == null
                      ? l10n.ghsPickTime
                      : formatDateTime(context, _at!),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _active
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _startOrStop,
                child: Text(
                  _active ? l10n.ghsStop : l10n.ghsStart,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
