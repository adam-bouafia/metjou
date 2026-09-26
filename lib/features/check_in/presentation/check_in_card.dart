import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/widgets/glass.dart';
import 'package:metjou/features/check_in/data/check_in_service.dart';

const _choices = [15, 30, 60, 120];
const _extendBy = 15;

/// Home card for the check-in timer: start it, see the time left, and
/// check in or add time.
class CheckInCard extends StatefulWidget {
  const CheckInCard({super.key});

  @override
  State<CheckInCard> createState() => _CheckInCardState();
}

class _CheckInCardState extends State<CheckInCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    CheckInService.deadline.addListener(_onDeadline);
    _onDeadline();
  }

  @override
  void dispose() {
    CheckInService.deadline.removeListener(_onDeadline);
    _ticker?.cancel();
    super.dispose();
  }

  /// Ticks once a second while a deadline runs, to update the time left.
  void _onDeadline() {
    _ticker?.cancel();
    if (CheckInService.deadline.value != null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
    if (mounted) setState(() {});
  }

  String _clock(DateTime time) => MaterialLocalizations.of(
    context,
  ).formatTimeOfDay(TimeOfDay.fromDateTime(time), alwaysUse24HourFormat: true);

  String _left(DateTime deadline) {
    final left = deadline.difference(DateTime.now());
    if (left.isNegative) return "0:00";
    final m = left.inMinutes;
    final s = (left.inSeconds % 60).toString().padLeft(2, '0');
    return m >= 60
        ? "${left.inHours}:${(m % 60).toString().padLeft(2, '0')}:$s"
        : "$m:$s";
  }

  Future<void> _start() async {
    final minutes = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.checkInHowLong,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in _choices)
                    ActionChip(
                      label: Text(context.l10n.minutes(m)),
                      onPressed: () => Navigator.pop(context, m),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (minutes == null || !mounted) return;
    await CheckInService.start(Duration(minutes: minutes), _clock);
  }

  Future<void> _checkIn() async {
    final done = context.l10n.checkInDone;
    await CheckInService.checkIn();
    Fluttertoast.showToast(msg: done);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final deadline = CheckInService.deadline.value;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: GlassPanel(
        onTap: deadline == null ? _start : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.timer_outlined, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.checkIn,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (deadline != null)
                    Text(
                      _left(deadline),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: scheme.primary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                deadline == null
                    ? l10n.checkInSubtitle
                    : l10n.checkInBefore(_clock(deadline)),
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              if (deadline != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _checkIn,
                        icon: const Icon(Icons.check),
                        label: Text(l10n.checkInSafe),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => CheckInService.extend(
                        const Duration(minutes: _extendBy),
                        _clock,
                      ),
                      child: Text(l10n.checkInExtend(_extendBy)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
