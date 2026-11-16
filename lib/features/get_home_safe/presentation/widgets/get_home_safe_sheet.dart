import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/theme/app_theme.dart';
import 'package:metjou/features/contacts/presentation/my_contacts.dart';
import 'package:metjou/features/get_home_safe/data/get_home_safe_service.dart';
import 'package:metjou/features/get_home_safe/presentation/get_home_safe_viewmodel.dart';

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
/// user started or stopped Get home safe. Reads and edits the same
/// [GetHomeSafeViewModel] the home card shows, so starting or stopping here
/// updates the card without either one refreshing the other.
class GetHomeSafeSheet extends ConsumerWidget {
  const GetHomeSafeSheet({super.key});

  Future<void> _pickCustomMinutes(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final controller = TextEditingController(text: "$current");
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
    if (minutes != null && minutes >= 1) {
      ref.read(getHomeSafeViewModelProvider.notifier).setMinutes(minutes);
    }
  }

  Future<void> _pickDateTime(
    BuildContext context,
    WidgetRef ref,
    DateTime? current,
  ) async {
    final now = DateTime.now();
    final initial = current ?? now.add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    ref
        .read(getHomeSafeViewModelProvider.notifier)
        .setAt(
          DateTime(date.year, date.month, date.day, time.hour, time.minute),
        );
  }

  Future<void> _startOrStop(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final action = await ref
        .read(getHomeSafeViewModelProvider.notifier)
        .startOrStop();
    switch (action) {
      case GhsAction.stopped:
        Fluttertoast.showToast(msg: l10n.getHomeSafeOff);
      case GhsAction.started:
        Fluttertoast.showToast(msg: l10n.getHomeSafeOn);
      case GhsAction.noContactSelected:
        Fluttertoast.showToast(msg: l10n.selectContactFirst);
        return;
      case GhsAction.timeInPast:
        Fluttertoast.showToast(msg: l10n.ghsTimeInPast);
        return;
    }
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(getHomeSafeViewModelProvider);
    final active = state.active;
    final contacts = state.contacts;
    final contact = state.selectedContact;
    final repeat = state.repeat;
    final minutes = state.minutes;
    final at = state.at;
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
            if (contacts.isEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.noContacts),
                subtitle: Text(l10n.addContactHint),
                trailing: const Icon(Icons.person_add_alt),
                onTap: () async {
                  await addSosContactFlow(context);
                  ref
                      .read(getHomeSafeViewModelProvider.notifier)
                      .reloadContacts();
                },
              )
            else
              RadioGroup<String>(
                groupValue: contact,
                onChanged: (value) {
                  if (!active) {
                    ref
                        .read(getHomeSafeViewModelProvider.notifier)
                        .selectContact(value);
                  }
                },
                child: Column(
                  children: [
                    for (final c in contacts)
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        value: c.phone,
                        enabled: !active,
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
              selected: {repeat},
              onSelectionChanged: active
                  ? null
                  : (s) => ref
                        .read(getHomeSafeViewModelProvider.notifier)
                        .setRepeat(s.first),
            ),
            const SizedBox(height: 12),
            if (repeat) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in _presetMinutes)
                    ChoiceChip(
                      label: Text(l10n.ghsEvery(m)),
                      selected: minutes == m,
                      onSelected: active
                          ? null
                          : (_) => ref
                                .read(getHomeSafeViewModelProvider.notifier)
                                .setMinutes(m),
                    ),
                  ChoiceChip(
                    label: Text(
                      _presetMinutes.contains(minutes)
                          ? l10n.ghsCustom
                          : l10n.ghsEvery(minutes),
                    ),
                    selected: !_presetMinutes.contains(minutes),
                    onSelected: active
                        ? null
                        : (_) => _pickCustomMinutes(context, ref, minutes),
                  ),
                ],
              ),
              if (minutes == 1) ...[
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
                onPressed: active
                    ? null
                    : () => _pickDateTime(context, ref, at),
                icon: const Icon(Icons.event),
                label: Text(
                  at == null ? l10n.ghsPickTime : formatDateTime(context, at),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: active
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _startOrStop(context, ref),
                child: Text(
                  active ? l10n.ghsStop : l10n.ghsStart,
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
