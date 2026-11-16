import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metjou/core/services/discreet_mode.dart';
import 'package:metjou/features/tracker_watch/data/follow_detector.dart';
import 'package:metjou/features/tracker_watch/data/sighting_store.dart';
import 'package:metjou/features/tracker_watch/data/tracker_scanner.dart';
import 'package:metjou/features/tracker_watch/data/tracker_watch.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_actions.dart';

const _unset = Object();

/// What the Tracker Scan screen shows.
class TrackerScanState {
  const TrackerScanState({
    this.watching = false,
    this.discreet = false,
    this.hasHistory = false,
    this.lastCheck,
    this.followers = const [],
    this.ignored = const {},
    this.watchBlocker,
    this.scanning = false,
    this.outcome,
  });

  final bool watching;
  final bool discreet;
  final bool hasHistory;
  final DateTime? lastCheck;
  final List<Follower> followers;
  final Set<String> ignored;
  final ScanBlocker? watchBlocker;
  final bool scanning;
  final ScanOutcome? outcome;

  TrackerScanState copyWith({
    bool? watching,
    bool? discreet,
    bool? hasHistory,
    DateTime? lastCheck,
    List<Follower>? followers,
    Set<String>? ignored,
    Object? watchBlocker = _unset,
    bool? scanning,
    ScanOutcome? outcome,
  }) => TrackerScanState(
    watching: watching ?? this.watching,
    discreet: discreet ?? this.discreet,
    hasHistory: hasHistory ?? this.hasHistory,
    lastCheck: lastCheck ?? this.lastCheck,
    followers: followers ?? this.followers,
    ignored: ignored ?? this.ignored,
    watchBlocker: watchBlocker == _unset
        ? this.watchBlocker
        : watchBlocker as ScanBlocker?,
    scanning: scanning ?? this.scanning,
    outcome: outcome ?? this.outcome,
  );
}

/// Holds the Tracker Scan screen's state: the background watch switch, the
/// last manual scan, and who is travelling with the user. The View only
/// reads [TrackerScanState] and calls these methods.
class TrackerScanViewModel extends Notifier<TrackerScanState> {
  SightingStore? _store;

  TrackerActions get _actions => ref.read(trackerActionsProvider);

  @override
  TrackerScanState build() {
    _reload();
    return const TrackerScanState();
  }

  Future<SightingStore> _resolveStore() async =>
      _store ??=
          ref.read(sightingStoreOverrideProvider) ?? await SightingStore.open();

  Future<void> _reload() async {
    final store = await _resolveStore();
    final watching = await TrackerWatch.isEnabled();
    final followers = await TrackerWatch.followers(store);
    final ignored = await TrackerWatch.ignored();
    final lastCheck = await TrackerWatch.lastCheck();
    final discreet = await DiscreetMode.isEnabled();
    final hasHistory = (await store.load()).isNotEmpty;
    state = state.copyWith(
      watching: watching,
      followers: followers,
      ignored: ignored,
      lastCheck: lastCheck,
      discreet: discreet,
      hasHistory: hasHistory,
    );
  }

  Future<void> setWatching(bool on) async {
    if (on) {
      final blocker = await _actions.checkWatch();
      state = state.copyWith(watchBlocker: blocker);
      if (blocker != null) return;
    }
    await _actions.setWatch(on);
    state = state.copyWith(watching: on, watchBlocker: null);
  }

  Future<void> scan() async {
    state = state.copyWith(scanning: true);
    final outcome = await _actions.scan();
    final store = _store;
    // With the watch on, a manual scan adds to the history like a
    // background round does.
    if (outcome.blocker == null && state.watching && store != null) {
      final here = await _actions.place();
      await TrackerWatch.record(
        store,
        outcome.trackers,
        at: DateTime.now(),
        lat: here?.lat,
        lon: here?.lon,
      );
      await _reload();
    }
    state = state.copyWith(scanning: false, outcome: outcome);
  }

  /// Re-reads everything, after returning from a screen that may have
  /// changed it (ignoring a tracker, for example).
  Future<void> refresh() => _reload();

  Future<void> deleteHistory() async {
    final store = _store;
    if (store == null) return;
    await TrackerWatch.deleteHistory(store);
    await _reload();
  }

  /// Stored sightings of [window], newest first, for a tracker just found
  /// by a manual scan.
  Future<List<Sighting>> recentSince(Duration window) async {
    final since = DateTime.now().subtract(window);
    return (await _store?.load(since: since) ?? []).reversed.toList();
  }
}

final trackerScanViewModelProvider =
    NotifierProvider<TrackerScanViewModel, TrackerScanState>(
      TrackerScanViewModel.new,
    );
