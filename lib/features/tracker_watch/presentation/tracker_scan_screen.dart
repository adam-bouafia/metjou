import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/services/discreet_mode.dart';
import 'package:metjou/core/theme/app_theme.dart';
import 'package:metjou/core/widgets/pin_guard.dart';
import 'package:metjou/features/tracker_watch/data/follow_detector.dart';
import 'package:metjou/features/tracker_watch/data/sighting_store.dart';
import 'package:metjou/features/tracker_watch/data/tracker_scanner.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:metjou/features/tracker_watch/data/tracker_text.dart';
import 'package:metjou/features/tracker_watch/data/tracker_watch.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_actions.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_detail_screen.dart';
import 'package:permission_handler/permission_handler.dart';

/// Opens the tracker screen after the PIN check (when a PIN is set): it
/// shows where trackers were seen, which is where the user has been.
Future<void> openTrackerScan(
  BuildContext context, {
  SightingStore? store,
}) async {
  if (!await confirmPin(context) || !context.mounted) return;
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => TrackerScanScreen(store: store)),
  );
}

/// Trackers that travel with the user, the switch for watching in the
/// background, and a scan of what is nearby right now.
class TrackerScanScreen extends StatefulWidget {
  const TrackerScanScreen({
    super.key,
    this.actions = const TrackerActions(),
    this.store,
  });

  final TrackerActions actions;

  /// Where sightings are kept; the app's own store when null.
  final SightingStore? store;

  @override
  State<TrackerScanScreen> createState() => _TrackerScanScreenState();
}

class _TrackerScanScreenState extends State<TrackerScanScreen> {
  SightingStore? _store;
  bool _watching = false;
  bool _discreet = false;
  bool _hasHistory = false;
  DateTime? _lastCheck;
  List<Follower> _followers = [];
  Set<String> _ignored = {};
  ScanBlocker? _watchBlocker;

  bool _scanning = false;
  ScanOutcome? _outcome;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final store = _store ?? widget.store ?? await SightingStore.open();
    final watching = await TrackerWatch.isEnabled();
    final followers = await TrackerWatch.followers(store);
    final ignored = await TrackerWatch.ignored();
    final lastCheck = await TrackerWatch.lastCheck();
    final discreet = await DiscreetMode.isEnabled();
    final hasHistory = (await store.load()).isNotEmpty;
    if (!mounted) return;
    setState(() {
      _store = store;
      _watching = watching;
      _followers = followers;
      _ignored = ignored;
      _lastCheck = lastCheck;
      _discreet = discreet;
      _hasHistory = hasHistory;
    });
  }

  Future<void> _setWatching(bool on) async {
    if (on) {
      final blocker = await widget.actions.checkWatch();
      if (!mounted) return;
      setState(() => _watchBlocker = blocker);
      if (blocker != null) return;
    }
    await widget.actions.setWatch(on);
    if (!mounted) return;
    setState(() {
      _watching = on;
      _watchBlocker = null;
    });
  }

  Future<void> _scan() async {
    setState(() => _scanning = true);
    final outcome = await widget.actions.scan();
    final store = _store;
    // With the watch on, a manual scan adds to the history like a
    // background round does.
    if (outcome.blocker == null && _watching && store != null) {
      final here = await widget.actions.place();
      await TrackerWatch.record(
        store,
        outcome.trackers,
        at: DateTime.now(),
        lat: here?.lat,
        lon: here?.lon,
      );
      await _reload();
    }
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _outcome = outcome;
    });
  }

  Future<void> _open(TrackerSubject subject) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TrackerDetailScreen(subject: subject, actions: widget.actions),
      ),
    );
    await _reload();
  }

  Future<void> _openScanned(Tracker tracker) async {
    final now = DateTime.now();
    final since = now.subtract(const FollowRule().window);
    final recent = (await _store?.load(since: since) ?? []).reversed.toList();
    await _open(TrackerSubject.ofScan(tracker, now, recent));
  }

  Future<void> _deleteHistory() async {
    final l10n = context.l10n;
    final store = _store;
    if (store == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.trackerDeleteHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await TrackerWatch.deleteHistory(store);
    await _reload();
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
    final followers = _followers.where((f) => !_ignored.contains(f.device));
    final ignored = _followers.where((f) => _ignored.contains(f.device));
    final lastCheck = _lastCheck;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trackerScan),
        actions: [
          if (_hasHistory)
            IconButton(
              tooltip: l10n.trackerDeleteHistory,
              onPressed: _deleteHistory,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (followers.isNotEmpty) ...[
            _Heading(l10n.trackerFollowersTitle),
            for (final follower in followers)
              _FollowerTile(
                follower: follower,
                // A caution, not an alarm: the tile leads to what to do.
                color: Latte.peach.withValues(alpha: 0.16),
                onTap: () => _open(TrackerSubject.ofFollower(follower)),
              ),
            const SizedBox(height: 8),
          ],
          Text(
            l10n.trackerScanIntro,
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SwitchListTile(
                value: _watching,
                onChanged: _setWatching,
                title: Text(l10n.trackerWatch),
                subtitle: Text(
                  [
                    l10n.trackerWatchSubtitle,
                    if (_watching && lastCheck != null)
                      l10n.trackerWatchLastCheck(clockTime(lastCheck)),
                    if (_watching && _discreet) l10n.trackerWatchDiscreet,
                  ].join("\n"),
                ),
              ),
            ),
          ),
          if (_watchBlocker case final blocker?) _BlockerCard(blocker: blocker),
          const SizedBox(height: 8),
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
            _Heading(l10n.trackerScanFound(trackers.length)),
            if (away > 0)
              Card(
                // A caution, not an alarm: most such tags are lost, not
                // planted.
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
            for (final tracker in trackers)
              _TrackerTile(
                tracker: tracker,
                onTap: () => _openScanned(tracker),
              ),
          ],
          if (ignored.isNotEmpty) ...[
            _Heading(l10n.trackerIgnoredTitle),
            for (final follower in ignored)
              _FollowerTile(
                follower: follower,
                onTap: () => _open(TrackerSubject.ofFollower(follower)),
              ),
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

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

IconData _iconOf(TrackerKind kind) =>
    kind == TrackerKind.airPods ? Icons.headphones : Icons.sell_outlined;

class _FollowerTile extends StatelessWidget {
  const _FollowerTile({
    required this.follower,
    required this.onTap,
    this.color,
  });

  final Follower follower;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      color: color,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          _iconOf(follower.kind),
          color: color == null ? null : Latte.peach,
        ),
        title: Text(trackerKindName(l10n, follower.kind)),
        subtitle: Text(followerSummary(l10n, follower)),
        trailing: Text(l10n.trackerCode(deviceCode(follower.device))),
      ),
    );
  }
}

class _TrackerTile extends StatelessWidget {
  const _TrackerTile({required this.tracker, required this.onTap});

  final Tracker tracker;
  final VoidCallback onTap;

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
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: Icon(_iconOf(tracker.kind), color: color),
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
