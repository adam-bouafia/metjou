import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/theme/app_theme.dart';
import 'package:metjou/features/tracker_watch/data/tracker_scanner.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:metjou/features/tracker_watch/data/tracker_text.dart';
import 'package:permission_handler/permission_handler.dart';

/// Looks once for trackers nearby and lists them, those away from their
/// owner first.
class TrackerScanScreen extends StatefulWidget {
  const TrackerScanScreen({super.key, this.scan = TrackerScanner.run});

  /// Runs one scan. Tests pass their own.
  final Future<ScanOutcome> Function() scan;

  @override
  State<TrackerScanScreen> createState() => _TrackerScanScreenState();
}

class _TrackerScanScreenState extends State<TrackerScanScreen> {
  bool _scanning = false;
  ScanOutcome? _outcome;

  Future<void> _scan() async {
    setState(() => _scanning = true);
    final outcome = await widget.scan();
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _outcome = outcome;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final outcome = _outcome;
    final blocker = outcome?.blocker;
    final trackers = outcome?.trackers ?? const <Tracker>[];
    final away = trackers.where((t) => t.owner == OwnerState.away).length;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.trackerScan)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            l10n.trackerScanIntro,
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _scanning ? null : _scan,
            icon: const Icon(Icons.bluetooth_searching),
            label: Text(
              _scanning
                  ? l10n.trackerScanRunning
                  : outcome == null
                  ? l10n.trackerScanStart
                  : l10n.trackerScanAgain,
            ),
          ),
          if (_scanning)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: manualScanDuration,
                builder: (_, value, _) => LinearProgressIndicator(value: value),
              ),
            ),
          const SizedBox(height: 12),
          if (!_scanning && blocker != null)
            _BlockerCard(blocker: blocker)
          else if (!_scanning && outcome != null && trackers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.trackerScanNone,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            )
          else if (!_scanning && outcome != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.trackerScanFound(trackers.length),
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (away > 0)
              Card(
                // A caution, not an alarm: most such tags are simply lost.
                color: Latte.peach.withValues(alpha: 0.16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.trackerScanAway(away),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.trackerScanAwayHint,
                        style: const TextStyle(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            for (final tracker in trackers) _TrackerTile(tracker: tracker),
          ],
          const SizedBox(height: 16),
          Text(
            l10n.trackerScanNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackerTile extends StatelessWidget {
  const _TrackerTile({required this.tracker});

  final Tracker tracker;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final (owner, color) = switch (tracker.owner) {
      OwnerState.away => (l10n.trackerOwnerAway, Latte.peach),
      OwnerState.near => (l10n.trackerOwnerNear, scheme.onSurfaceVariant),
      OwnerState.unknown => (l10n.trackerOwnerUnknown, scheme.tertiary),
    };
    final proximity = switch (tracker.proximity) {
      Proximity.veryClose => l10n.trackerVeryClose,
      Proximity.close => l10n.trackerClose,
      Proximity.far => l10n.trackerFar,
    };
    return Card(
      child: ListTile(
        leading: Icon(
          tracker.kind == TrackerKind.airPods
              ? Icons.headphones
              : Icons.sell_outlined,
          color: color,
        ),
        title: Text(trackerKindName(l10n, tracker.kind)),
        subtitle: Text("$owner · $proximity"),
        trailing: Text(l10n.trackerCode(deviceCode(tracker.id))),
      ),
    );
  }
}

class _BlockerCard extends StatelessWidget {
  const _BlockerCard({required this.blocker});

  final ScanBlocker blocker;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = switch (blocker) {
      ScanBlocker.unsupported => l10n.trackerBlockedUnsupported,
      ScanBlocker.bluetoothOff => l10n.trackerBlockedBluetooth,
      ScanBlocker.permissionDenied => l10n.trackerBlockedPermission,
      ScanBlocker.locationOff => l10n.trackerBlockedLocation,
      ScanBlocker.backgroundLocation => l10n.trackerBlockedBackground,
      ScanBlocker.failed => l10n.trackerBlockedFailed,
    };
    // Only these have a settings page the app can open.
    final openSettings = switch (blocker) {
      ScanBlocker.permissionDenied => openAppSettings,
      ScanBlocker.backgroundLocation => openAppSettings,
      ScanBlocker.locationOff => Geolocator.openLocationSettings,
      _ => null,
    };
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(color: scheme.onPrimaryContainer, height: 1.4),
            ),
            if (openSettings != null)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: openSettings,
                  child: Text(l10n.openSettings),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
