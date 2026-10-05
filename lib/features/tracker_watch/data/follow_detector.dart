import 'dart:math';

import 'package:metjou/features/tracker_watch/data/sighting_store.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';

/// When a tracker counts as travelling with the user. The defaults are the
/// ones of the AirGuard app at its medium sensitivity.
class FollowRule {
  const FollowRule({
    this.window = const Duration(hours: 24),
    this.minSightings = 3,
    this.minDuration = const Duration(minutes: 60),
    this.minPlaces = 3,
    this.placeRadius = 150,
  });

  /// Only sightings this recent count.
  final Duration window;
  final int minSightings;

  /// Least time between the first and the last sighting.
  final Duration minDuration;

  /// Least number of different places it was seen at.
  final int minPlaces;

  /// Sightings closer together than this, in metres, are one place.
  final double placeRadius;

  /// Places needed for a tracker of [kind]. Tile and Pebblebee tags never
  /// say whether their owner is near, so the tag of someone who happens to
  /// travel the same way counts too; they need one place more (AirGuard
  /// does the same for Tile).
  int placesNeeded(TrackerKind kind) =>
      kind == TrackerKind.tile || kind == TrackerKind.pebblebee
      ? minPlaces + 1
      : minPlaces;
}

/// A tracker that has been travelling with the user.
class Follower {
  const Follower({
    required this.device,
    required this.sightings,
    required this.places,
  });

  final String device;

  /// Its sightings inside the rule's window, oldest first.
  final List<Sighting> sightings;

  /// How many different places it was seen at.
  final int places;

  TrackerKind get kind => sightings.last.kind;
  DateTime get firstSeen => sightings.first.at;
  DateTime get lastSeen => sightings.last.at;

  /// Its most recent Bluetooth address.
  String get address => sightings.last.address;
}

/// Distance in metres between two points (haversine formula).
double distanceMeters(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371000.0;
  double rad(double degrees) => degrees * pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLon = rad(lon2 - lon1);
  final a =
      pow(sin(dLat / 2), 2) +
      cos(rad(lat1)) * cos(rad(lat2)) * pow(sin(dLon / 2), 2);
  return 2 * earthRadius * asin(sqrt(a));
}

/// The places among [sightings]: one sighting per place, where a place is
/// everything within [radius] metres of its first sighting.
List<Sighting> distinctPlaces(Iterable<Sighting> sightings, double radius) {
  final places = <Sighting>[];
  for (final s in sightings.where((s) => s.hasPlace)) {
    final known = places.any(
      (p) => distanceMeters(p.lat!, p.lon!, s.lat!, s.lon!) <= radius,
    );
    if (!known) places.add(s);
  }
  return places;
}

/// The trackers in [sightings] that meet [rule] at [now], most recently
/// seen first.
List<Follower> findFollowers(
  Iterable<Sighting> sightings, {
  required DateTime now,
  FollowRule rule = const FollowRule(),
}) {
  final since = now.subtract(rule.window);
  final byDevice = <String, List<Sighting>>{};
  for (final s in sightings) {
    if (s.at.isBefore(since) || s.at.isAfter(now)) continue;
    byDevice.putIfAbsent(s.device, () => []).add(s);
  }
  final followers = <Follower>[];
  for (final MapEntry(key: device, value: seen) in byDevice.entries) {
    if (seen.length < rule.minSightings) continue;
    seen.sort((a, b) => a.at.compareTo(b.at));
    if (seen.last.at.difference(seen.first.at) < rule.minDuration) continue;
    final places = distinctPlaces(seen, rule.placeRadius).length;
    if (places < rule.placesNeeded(seen.last.kind)) continue;
    followers.add(Follower(device: device, sightings: seen, places: places));
  }
  return followers..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
}

// A SmartTag away from its owner changes its id every 15 minutes, but its
// aging counter keeps ticking once per 15 minutes from the day it was set
// up. So "counter x 15 minutes - clock" stays inside one 15-minute band for
// the whole life of a tag, and differs between tags set up at other times.
const _agingStepMinutes = 15;
const _agingSlackMinutes = 0.5;

double _agingOffset(int aging, DateTime at) =>
    aging * _agingStepMinutes - at.millisecondsSinceEpoch / 60000;

/// True when [seen] at [at] is the tracker of the [earlier] sighting.
bool isSameTracker(Tracker seen, DateTime at, Sighting earlier) {
  if (seen.id == earlier.id || seen.id == earlier.device) return true;
  final aging = seen.aging;
  final before = earlier.aging;
  if (seen.kind != TrackerKind.smartTag ||
      earlier.kind != TrackerKind.smartTag ||
      aging == null ||
      before == null) {
    return false;
  }
  final drift = _agingOffset(aging, at) - _agingOffset(before, earlier.at);
  return drift.abs() < _agingStepMinutes + _agingSlackMinutes;
}

/// The device key for [seen]: the key of an earlier sighting of the same
/// tracker in [recent], or its own id when it is new.
String resolveDevice(Tracker seen, DateTime at, Iterable<Sighting> recent) {
  for (final earlier in recent) {
    if (isSameTracker(seen, at, earlier)) return earlier.device;
  }
  return seen.id;
}

/// True when [next] says nothing new after [last]: the same tracker again
/// within ten minutes at the same place. Keeps a row of manual scans from
/// filling the log.
bool isRepeat(Sighting next, Sighting last, {double placeRadius = 150}) {
  if (next.at.difference(last.at).abs() >= const Duration(minutes: 10)) {
    return false;
  }
  if (next.hasPlace != last.hasPlace) return false;
  if (!next.hasPlace) return true;
  return distanceMeters(last.lat!, last.lon!, next.lat!, next.lon!) <=
      placeRadius;
}
