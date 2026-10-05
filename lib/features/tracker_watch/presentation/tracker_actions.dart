import 'package:metjou/features/tracker_watch/data/follow_detector.dart';
import 'package:metjou/features/tracker_watch/data/sighting_store.dart';
import 'package:metjou/features/tracker_watch/data/tracker_scanner.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:metjou/features/tracker_watch/data/tracker_sound.dart';
import 'package:metjou/features/tracker_watch/data/tracker_watch.dart';
import 'package:tracker_scan/tracker_scan.dart';

Stream<Tracker> _liveTrackers() => TrackerScan.live(
  filters: trackerFilters,
).map(identifyTracker).where((t) => t != null).cast<Tracker>();

/// The platform calls behind the tracker screens. Tests pass their own.
class TrackerActions {
  const TrackerActions({
    this.scan = TrackerScanner.run,
    this.checkWatch = TrackerWatch.check,
    this.setWatch = TrackerWatch.setEnabled,
    this.place = TrackerWatch.place,
    this.live = _liveTrackers,
    this.playSound = TrackerSound.play,
  });

  /// One scan, after the permission checks.
  final Future<ScanOutcome> Function() scan;

  /// What stops background watching, or null.
  final Future<ScanBlocker?> Function() checkWatch;
  final Future<void> Function(bool enabled) setWatch;

  /// Where the phone is now, when known well enough.
  final Future<({double lat, double lon})?> Function() place;

  /// Trackers as their adverts arrive, until the listener cancels.
  final Stream<Tracker> Function() live;
  final Future<SoundResult> Function(TrackerKind kind, String address)
  playSound;
}

/// The tracker a detail or finder screen is about.
class TrackerSubject {
  const TrackerSubject({
    required this.device,
    required this.last,
    this.history = const [],
  });

  TrackerSubject.ofFollower(Follower follower)
    : device = follower.device,
      last = follower.sightings.last,
      history = follower.sightings;

  /// A tracker from a scan at [at], with what [recent] (newest first) holds
  /// about it.
  factory TrackerSubject.ofScan(
    Tracker tracker,
    DateTime at,
    List<Sighting> recent,
  ) {
    final device = resolveDevice(tracker, at, recent);
    return TrackerSubject(
      device: device,
      last: Sighting(
        device: device,
        kind: tracker.kind,
        at: at,
        address: tracker.address,
        id: tracker.id,
        rssi: tracker.rssi,
        aging: tracker.aging,
      ),
      history: recent
          .where((s) => s.device == device)
          .toList()
          .reversed
          .toList(),
    );
  }

  /// Key under which its sightings are stored.
  final String device;

  /// The most recent time it was seen.
  final Sighting last;

  /// Stored sightings of the last day, oldest first.
  final List<Sighting> history;

  TrackerKind get kind => last.kind;

  /// True when [seen] at [at] is this tracker.
  bool matches(Tracker seen, DateTime at) =>
      seen.address == last.address || isSameTracker(seen, at, last);
}
