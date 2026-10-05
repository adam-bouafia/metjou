import 'dart:async';

import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/features/tracker_watch/data/signal_meter.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:metjou/features/tracker_watch/data/tracker_text.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_actions.dart';

/// Shows how strong one tracker's signal is while the user walks around, to
/// find where it is hidden.
class TrackerFinderScreen extends StatefulWidget {
  const TrackerFinderScreen({
    super.key,
    required this.subject,
    this.actions = const TrackerActions(),
  });

  final TrackerSubject subject;
  final TrackerActions actions;

  @override
  State<TrackerFinderScreen> createState() => _TrackerFinderScreenState();
}

/// After this many seconds without a reading the tracker counts as out of
/// range.
const _lostAfterSeconds = 6;

class _TrackerFinderScreenState extends State<TrackerFinderScreen> {
  final _meter = SignalMeter();
  StreamSubscription<Tracker>? _adverts;
  Timer? _tick;
  int _quietSeconds = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _adverts = widget.actions.live().listen((seen) {
      if (!widget.subject.matches(seen, DateTime.now())) return;
      setState(() {
        _meter.add(seen.rssi);
        _quietSeconds = 0;
      });
    }, onError: (Object _) => setState(() => _failed = true));
    // Counts the seconds without a reading, to notice a lost signal.
    _tick = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _quietSeconds++),
    );
  }

  @override
  void dispose() {
    _adverts?.cancel();
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final heard = _meter.level != null;
    final lost = _quietSeconds > _lostAfterSeconds;
    final String status;
    if (_failed) {
      status = l10n.trackerBlockedFailed;
    } else if (!heard) {
      status = l10n.trackerFinderSearching;
    } else if (lost) {
      status = l10n.trackerFinderLost;
    } else {
      status = switch (_meter.trend) {
        SignalTrend.closer => l10n.trackerFinderCloser,
        SignalTrend.further => l10n.trackerFinderFurther,
        SignalTrend.steady => "",
      };
    }
    final distance = switch (_meter.proximity) {
      Proximity.veryClose => l10n.trackerVeryClose,
      Proximity.close => l10n.trackerClose,
      Proximity.far => l10n.trackerFar,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l10n.trackerFind)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Text(
            "${trackerKindName(l10n, widget.subject.kind)} · "
            "${l10n.trackerCode(deviceCode(widget.subject.device))}",
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 32),
          Center(
            child: SizedBox.square(
              dimension: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: heard && !lost ? _meter.strength : 0),
                    duration: const Duration(milliseconds: 400),
                    builder: (_, value, _) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 16,
                      strokeCap: StrokeCap.round,
                      backgroundColor: scheme.surfaceContainerHighest,
                    ),
                  ),
                  Center(
                    child: heard && !lost
                        ? Text(
                            distance,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall,
                          )
                        : Icon(
                            Icons.bluetooth_searching,
                            size: 48,
                            color: scheme.onSurfaceVariant,
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Fixed height, so the hint below does not jump as the text changes.
          SizedBox(
            height: 56,
            child: Text(
              status,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.primary,
              ),
            ),
          ),
          Text(
            l10n.trackerFinderHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
          ),
        ],
      ),
    );
  }
}
