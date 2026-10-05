import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/features/tracker_watch/data/follow_detector.dart';
import 'package:metjou/features/tracker_watch/data/sighting_store.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:metjou/features/tracker_watch/data/tracker_watch.dart';
import 'package:shared_preferences/shared_preferences.dart';

Tracker tracker(
  String address, {
  OwnerState owner = OwnerState.away,
  TrackerKind kind = TrackerKind.airTag,
  String? id,
  int? aging,
}) => Tracker(
  kind: kind,
  owner: owner,
  address: address,
  rssi: -58,
  id: id,
  aging: aging,
);

void main() {
  late Directory dir;
  late SightingStore store;
  final start = DateTime(2026, 10, 5, 18);

  DateTime at(int minutes) => start.add(Duration(minutes: minutes));

  /// One watch round: what was seen, and where the phone was (a step is
  /// about 222 m, so every step is a new place).
  Future<Set<String>> round(
    int minutes,
    List<Tracker> trackers, {
    int? place,
  }) => TrackerWatch.record(
    store,
    trackers,
    at: at(minutes),
    lat: place == null ? null : 52.37 + place * 0.002,
    lon: place == null ? null : 4.89,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('tracker_watch_test');
    store = SightingStore.at(dir);
  });

  tearDown(() => dir.delete(recursive: true));

  test('is off until switched on', () async {
    expect(await TrackerWatch.isEnabled(), isFalse);
    expect(await TrackerWatch.lastCheck(), isNull);
  });

  test('record keeps trackers away from their owner, not the others', () async {
    final seen = await round(0, [
      tracker('AA:01'),
      tracker('AA:02', owner: OwnerState.unknown, kind: TrackerKind.tile),
      tracker('AA:03', owner: OwnerState.near),
    ], place: 0);
    expect(seen, {'AA:01', 'AA:02'});
    final stored = await store.load();
    expect(stored.map((s) => s.device), ['AA:01', 'AA:02']);
    expect(stored.first.at, start);
    expect(stored.first.rssi, -58);
    expect(stored.first.hasPlace, isTrue);
    expect(stored.last.kind, TrackerKind.tile);
  });

  test('record writes nothing when every tracker is with its owner', () async {
    expect(await round(0, [tracker('AA:03', owner: OwnerState.near)]), isEmpty);
    expect(await store.load(), isEmpty);
  });

  test('a repeat within minutes at the same place is not stored again, '
      'but still counts as seen', () async {
    await round(0, [tracker('AA:01')], place: 0);
    expect(await round(2, [tracker('AA:01')], place: 0), {'AA:01'});
    expect(await store.load(), hasLength(1));
    await round(4, [tracker('AA:01')], place: 1);
    expect(await store.load(), hasLength(2));
  });

  test('a SmartTag that changes its id keeps one device key', () async {
    // Set up 1000 minutes before the start; the counter ticks every 15.
    int counter(int minutes) => (1000 + minutes) ~/ 15;
    for (final minutes in [0, 16, 31, 62]) {
      final seen = await round(minutes, [
        tracker(
          'BB:$minutes',
          kind: TrackerKind.smartTag,
          id: 'privacy-$minutes',
          aging: counter(minutes),
        ),
      ], place: minutes);
      expect(seen, {'privacy-0'});
    }
    final stored = await store.load();
    expect(stored.map((s) => s.device).toSet(), {'privacy-0'});
    expect(stored.last.address, 'BB:62');
    expect(await TrackerWatch.followers(store, now: at(62)), hasLength(1));
  });

  test('a tracker that comes along for an hour becomes a follower', () async {
    await round(0, [tracker('AA:01'), tracker('AA:09')], place: 0);
    await round(15, [tracker('AA:01')], place: 1);
    expect(await TrackerWatch.followers(store, now: at(15)), isEmpty);
    await round(30, [tracker('AA:01')], place: 2);
    expect(await TrackerWatch.followers(store, now: at(30)), isEmpty);
    await round(60, [tracker('AA:01')], place: 3);
    final follower = (await TrackerWatch.followers(store, now: at(60))).single;
    expect(follower.device, 'AA:01');
    expect(follower.places, 4);
  });

  test('on the way home half an hour at two places is enough', () async {
    await round(0, [tracker('AA:01')], place: 0);
    await round(15, [tracker('AA:01')], place: 1);
    await round(31, [tracker('AA:01')], place: 1);
    expect(await TrackerWatch.followers(store, now: at(31)), isEmpty);
    final follower = (await TrackerWatch.followers(
      store,
      now: at(31),
      rule: journeyRule,
    )).single;
    expect(follower.device, 'AA:01');
    expect(follower.places, 2);
  });

  test('the journey timer can be started twice and stopped', () {
    TrackerWatch.startJourney();
    TrackerWatch.startJourney();
    TrackerWatch.stopJourney();
    TrackerWatch.stopJourney();
  });

  test('a tracker at home all evening is never a follower', () async {
    for (var minutes = 0; minutes <= 240; minutes += 15) {
      await round(minutes, [tracker('AA:01')], place: 0);
    }
    expect(await TrackerWatch.followers(store, now: at(240)), isEmpty);
  });

  group('alerts', () {
    Future<List<Follower>> followerOf(String address) async {
      await round(0, [tracker(address)], place: 0);
      await round(30, [tracker(address)], place: 1);
      await round(60, [tracker(address)], place: 2);
      return TrackerWatch.followers(store, now: at(60));
    }

    test('warns once, then again after four hours', () async {
      final followers = await followerOf('AA:01');
      Future<int> due(int minutes) async => (await TrackerWatch.takeDueAlerts(
        followers,
        {'AA:01'},
        at(minutes),
      )).length;
      expect(await due(60), 1);
      expect(await due(75), 0);
      expect(await due(60 + 239), 0);
      expect(await due(60 + 240), 1);
    });

    test('does not warn about a follower that is gone', () async {
      final followers = await followerOf('AA:01');
      expect(
        await TrackerWatch.takeDueAlerts(followers, {'AA:77'}, at(75)),
        isEmpty,
      );
      // Nothing was remembered, so it warns as soon as it is back.
      expect(
        await TrackerWatch.takeDueAlerts(followers, {'AA:01'}, at(90)),
        hasLength(1),
      );
    });

    test('does not warn about an ignored tracker', () async {
      final followers = await followerOf('AA:01');
      await TrackerWatch.setIgnored('AA:01', true);
      expect(await TrackerWatch.ignored(), {'AA:01'});
      expect(
        await TrackerWatch.takeDueAlerts(followers, {'AA:01'}, at(60)),
        isEmpty,
      );
      await TrackerWatch.setIgnored('AA:01', false);
      expect(await TrackerWatch.ignored(), isEmpty);
      expect(
        await TrackerWatch.takeDueAlerts(followers, {'AA:01'}, at(60)),
        hasLength(1),
      );
    });

    test('deleting the history also forgets the warnings', () async {
      final followers = await followerOf('AA:01');
      await TrackerWatch.takeDueAlerts(followers, {'AA:01'}, at(60));
      await TrackerWatch.deleteHistory(store);
      expect(await store.load(), isEmpty);
      expect(
        await TrackerWatch.takeDueAlerts(followers, {'AA:01'}, at(61)),
        hasLength(1),
      );
    });
  });

  test('ignoring the same tracker twice keeps one entry', () async {
    await TrackerWatch.setIgnored('AA:01', true);
    await TrackerWatch.setIgnored('AA:02', true);
    await TrackerWatch.setIgnored('AA:01', true);
    expect(await TrackerWatch.ignored(), {'AA:01', 'AA:02'});
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('trackerIgnored'), ['AA:02', 'AA:01']);
  });
}
