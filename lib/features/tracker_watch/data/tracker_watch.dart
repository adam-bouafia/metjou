import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/services/background_services.dart';
import 'package:metjou/core/services/discreet_mode.dart';
import 'package:metjou/features/tracker_watch/data/follow_detector.dart';
import 'package:metjou/features/tracker_watch/data/sighting_store.dart';
import 'package:metjou/features/tracker_watch/data/tracker_scanner.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:metjou/features/tracker_watch/data/tracker_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const trackerWatchTask = "tracker-watch";
const _enabledKey = "trackerWatch";
const _ignoredKey = "trackerIgnored";
const _alertedKey = "trackerAlerted";
const _lastCheckKey = "trackerLastCheck";
const _prunedKey = "trackerPruned";

/// A background scan listens this long, as AirGuard does.
const backgroundScanDuration = Duration(seconds: 20);

/// At most one warning per tracker in this time.
const alertPause = Duration(hours: 4);

/// Sightings older than this are removed: long enough to show a pattern to
/// the police, short enough not to keep a movement history for ever.
const sightingRetention = Duration(days: 14);

/// A fix older or vaguer than this is not stored with a sighting. A stale
/// or jumping location would count as a new place and cause false warnings.
const maxPlaceAge = Duration(minutes: 5);
const maxPlaceAccuracyMeters = 100.0;

const _maxIgnored = 200;

/// Watches for trackers that travel with the user: a Workmanager task scans
/// every 15 minutes, stores what is away from its owner and warns when the
/// same tracker shows up at several places.
abstract final class TrackerWatch {
  static Future<SharedPreferences> _freshPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs;
  }

  static Future<bool> isEnabled() async =>
      (await _freshPrefs()).getBool(_enabledKey) ?? false;

  static Future<void> setEnabled(bool enabled) async {
    await (await SharedPreferences.getInstance()).setBool(_enabledKey, enabled);
    if (enabled) {
      await Workmanager().registerPeriodicTask(
        trackerWatchTask,
        trackerWatchTask,
        frequency: const Duration(minutes: 15),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
    } else {
      await Workmanager().cancelByUniqueName(trackerWatchTask);
    }
  }

  /// What stops background watching, or null when it can run. Asks for the
  /// permissions it needs.
  static Future<ScanBlocker?> check() async {
    final blocker = await TrackerScanner.check();
    if (blocker != null) return blocker;
    // Android only hands scan results to a closed app that may use the
    // location all the time.
    if (!await Permission.locationAlways.request().isGranted) {
      return ScanBlocker.backgroundLocation;
    }
    return null;
  }

  /// When the background task last ran, or null.
  static Future<DateTime?> lastCheck() async {
    final ms = (await _freshPrefs()).getInt(_lastCheckKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Where the phone is, when there is a recent and precise enough fix.
  static Future<({double lat, double lon})?> place() async {
    try {
      final position = await BackgroundServices.currentPosition();
      if (position == null ||
          DateTime.now().difference(position.timestamp).abs() > maxPlaceAge ||
          position.accuracy > maxPlaceAccuracyMeters) {
        return null;
      }
      return (lat: position.latitude, lon: position.longitude);
    } catch (e) {
      debugPrint("tracker watch position: $e");
      return null;
    }
  }

  /// Adds the [trackers] seen at [at] to [store], except those with their
  /// owner. Returns the device keys of the ones that count, also when a
  /// sighting was left out as a repeat.
  static Future<Set<String>> record(
    SightingStore store,
    Iterable<Tracker> trackers, {
    required DateTime at,
    double? lat,
    double? lon,
  }) async {
    final away = trackers.where((t) => t.owner != OwnerState.near).toList();
    if (away.isEmpty) return {};
    final since = at.subtract(const FollowRule().window);
    final known = (await store.load(since: since)).reversed.toList();
    final added = <Sighting>[];
    final devices = <String>{};
    for (final tracker in away) {
      final device = resolveDevice(tracker, at, known);
      devices.add(device);
      final sighting = Sighting(
        device: device,
        kind: tracker.kind,
        at: at,
        address: tracker.address,
        id: tracker.id,
        rssi: tracker.rssi,
        lat: lat,
        lon: lon,
        aging: tracker.aging,
      );
      final last = known.where((s) => s.device == device).firstOrNull;
      if (last == null || !isRepeat(sighting, last)) added.add(sighting);
    }
    await store.append(added);
    return devices;
  }

  /// The trackers travelling with the user at [now], ignored ones included.
  static Future<List<Follower>> followers(
    SightingStore store, {
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final since = at.subtract(const FollowRule().window);
    return findFollowers(await store.load(since: since), now: at);
  }

  /// Device keys the user chose not to be warned about.
  static Future<Set<String>> ignored() async =>
      ((await _freshPrefs()).getStringList(_ignoredKey) ?? const []).toSet();

  static Future<void> setIgnored(String device, bool ignore) async {
    final prefs = await _freshPrefs();
    final list = [...?prefs.getStringList(_ignoredKey)]..remove(device);
    if (ignore) list.add(device);
    // Trackers change their key over time; drop the oldest entries.
    final kept = list.length > _maxIgnored
        ? list.sublist(list.length - _maxIgnored)
        : list;
    await prefs.setStringList(_ignoredKey, kept);
  }

  /// The [followers] to warn about at [now]: seen in this round, not
  /// ignored, and not warned about in the last four hours. Remembers the
  /// warning.
  static Future<List<Follower>> takeDueAlerts(
    List<Follower> followers,
    Set<String> seenNow,
    DateTime now,
  ) async {
    final prefs = await _freshPrefs();
    final skip = (prefs.getStringList(_ignoredKey) ?? const []).toSet();
    final alerted = (jsonDecode(prefs.getString(_alertedKey) ?? "{}") as Map)
        .cast<String, int>();
    final nowMs = now.millisecondsSinceEpoch;
    final due = [
      for (final f in followers)
        if (seenNow.contains(f.device) &&
            !skip.contains(f.device) &&
            nowMs - (alerted[f.device] ?? 0) >= alertPause.inMilliseconds)
          f,
    ];
    if (due.isEmpty) return due;
    for (final f in due) {
      alerted[f.device] = nowMs;
    }
    alerted.removeWhere(
      (_, ms) => nowMs - ms > sightingRetention.inMilliseconds,
    );
    await prefs.setString(_alertedKey, jsonEncode(alerted));
    return due;
  }

  /// Removes the stored sightings and warning times.
  static Future<void> deleteHistory(SightingStore store) async {
    await store.clear();
    await (await SharedPreferences.getInstance()).remove(_alertedKey);
  }

  /// One round of the Workmanager task: scan, store, warn.
  static Future<void> backgroundCheck() async {
    try {
      if (!await isEnabled()) return;
      // No questions in the background: with Bluetooth off or a permission
      // withdrawn the scan reports a blocker and this round does nothing.
      final outcome = await TrackerScanner.scan(
        duration: backgroundScanDuration,
      );
      if (outcome.blocker != null) return;
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastCheckKey, now.millisecondsSinceEpoch);
      final store = await SightingStore.open();
      // The GPS is only asked when there is something to store.
      final away = outcome.trackers.any((t) => t.owner != OwnerState.near);
      final here = away ? await place() : null;
      final seenNow = await record(
        store,
        outcome.trackers,
        at: now,
        lat: here?.lat,
        lon: here?.lon,
      );
      final due = await takeDueAlerts(
        await followers(store, now: now),
        seenNow,
        now,
      );
      // Discreet mode: no notification; the app shows the warning instead.
      if (due.isNotEmpty && !await DiscreetMode.isEnabled()) {
        final text = trackerAlertText(await backgroundLocalizations(), due);
        // This isolate has not set the notification plugin up yet.
        await BackgroundServices.init();
        await BackgroundServices.showTrackerNotification(
          title: text.title,
          body: text.body,
        );
      }
      final pruned = prefs.getInt(_prunedKey) ?? 0;
      if (now.millisecondsSinceEpoch - pruned > Duration.millisecondsPerDay) {
        await store.prune(now.subtract(sightingRetention));
        await prefs.setInt(_prunedKey, now.millisecondsSinceEpoch);
      }
    } catch (e) {
      // A failed round must not fail the task: the next one runs anyway.
      debugPrint("tracker watch: $e");
    }
  }
}
