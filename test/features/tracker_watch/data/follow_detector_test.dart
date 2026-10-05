import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/features/tracker_watch/data/follow_detector.dart';
import 'package:metjou/features/tracker_watch/data/sighting_store.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';

final start = DateTime(2026, 10, 5, 18);

/// About 222 m per step north, so every step is a new place.
Sighting seen(
  String device,
  int minutes, {
  int? place,
  TrackerKind kind = TrackerKind.airTag,
  String? id,
  int? aging,
}) => Sighting(
  device: device,
  kind: kind,
  at: start.add(Duration(minutes: minutes)),
  address: 'AA:00:00:00:00:$device',
  rssi: -60,
  id: id,
  lat: place == null ? null : 52.37 + place * 0.002,
  lon: place == null ? null : 4.89,
  aging: aging,
);

Tracker smartTag(String id, int aging) => Tracker(
  kind: TrackerKind.smartTag,
  owner: OwnerState.away,
  address: 'AA:00:00:00:00:99',
  rssi: -60,
  id: id,
  aging: aging,
);

void main() {
  final later = start.add(const Duration(hours: 2));

  test('distanceMeters matches a known distance', () {
    // Amsterdam Centraal to Dam Square, about 850 m.
    final d = distanceMeters(52.3791, 4.9003, 52.3731, 4.8926);
    expect(d, closeTo(850, 30));
    expect(distanceMeters(52.37, 4.89, 52.37, 4.89), 0);
  });

  test('distinctPlaces merges what is within the radius', () {
    final places = distinctPlaces([
      seen('1', 0, place: 0),
      seen('1', 5, place: 0),
      seen('1', 10), // no location
      seen('1', 15, place: 1),
      seen('1', 20, place: 5),
    ], 150);
    expect(places.map((s) => s.at.minute), [0, 15, 20]);
    // With a wide radius the first two places are one.
    expect(
      distinctPlaces([seen('1', 0, place: 0), seen('1', 15, place: 1)], 300),
      hasLength(1),
    );
  });

  test('a tracker seen over an hour at three places is a follower', () {
    final found = findFollowers([
      seen('1', 0, place: 0),
      seen('1', 30, place: 1),
      seen('1', 65, place: 2),
    ], now: later).single;
    expect(found.device, '1');
    expect(found.kind, TrackerKind.airTag);
    expect(found.places, 3);
    expect(found.sightings, hasLength(3));
    expect(found.firstSeen, start);
    expect(found.lastSeen, start.add(const Duration(minutes: 65)));
    expect(found.address, 'AA:00:00:00:00:1');
  });

  final notEnough = <(String, List<Sighting>)>[
    ('only two sightings', [seen('1', 0, place: 0), seen('1', 65, place: 2)]),
    (
      'less than an hour',
      [
        seen('1', 0, place: 0),
        seen('1', 20, place: 1),
        seen('1', 59, place: 2),
      ],
    ),
    (
      'only two places',
      [
        seen('1', 0, place: 0),
        seen('1', 30, place: 1),
        seen('1', 65, place: 1),
      ],
    ),
    ('no locations at all', [seen('1', 0), seen('1', 30), seen('1', 65)]),
    (
      'the same place all evening',
      [for (var m = 0; m <= 180; m += 15) seen('1', m, place: 0)],
    ),
    (
      'sightings older than a day',
      [
        seen('1', -60 * 30, place: 0),
        seen('1', -60 * 29, place: 1),
        seen('1', 65, place: 2),
      ],
    ),
    (
      'three trackers seen once each',
      [
        seen('1', 0, place: 0),
        seen('2', 30, place: 1),
        seen('3', 65, place: 2),
      ],
    ),
  ];
  for (final (name, sightings) in notEnough) {
    test('no follower with $name', () {
      expect(findFollowers(sightings, now: later), isEmpty);
    });
  }

  test('followers come most recently seen first, each with its own data', () {
    final found = findFollowers([
      for (final (device, offset) in [('1', 0), ('2', 20)]) ...[
        seen(device, offset, place: 0),
        seen(device, offset + 30, place: 1),
        seen(device, offset + 65, place: 2),
      ],
    ], now: later);
    expect(found.map((f) => f.device), ['2', '1']);
    expect(found.every((f) => f.sightings.length == 3), isTrue);
  });

  test('the rule can be stricter or looser', () {
    final sightings = [
      seen('1', 0, place: 0),
      seen('1', 20, place: 1),
      seen('1', 35, place: 1),
    ];
    expect(findFollowers(sightings, now: later), isEmpty);
    const sensitive = FollowRule(
      minDuration: Duration(minutes: 30),
      minPlaces: 2,
    );
    expect(findFollowers(sightings, now: later, rule: sensitive), hasLength(1));
  });

  group('resolveDevice', () {
    final airTag = Tracker(
      kind: TrackerKind.airTag,
      owner: OwnerState.away,
      address: '4C:00:00:00:00:01',
      rssi: -60,
    );

    test('a new tracker gets its own id', () {
      expect(resolveDevice(airTag, start, []), airTag.id);
      expect(resolveDevice(airTag, start, [seen('other', 0)]), airTag.id);
    });

    test('the same id maps to the device seen before', () {
      final earlier = seen('first-id', 0, id: '4C:00:00:00:00:01');
      expect(resolveDevice(airTag, start, [earlier]), 'first-id');
    });

    // A SmartTag set up 1000 minutes before `start` shows counter
    // (1000 + minutes) ~/ 15 and a new id every 15 minutes.
    int counter(int minutes, {int setUpAgo = 1000}) =>
        (setUpAgo + minutes) ~/ 15;

    test('a SmartTag is followed across id changes by its counter', () {
      final first = seen(
        'tag-a',
        0,
        kind: TrackerKind.smartTag,
        id: 'id-0',
        aging: counter(0),
      );
      for (final minutes in [14, 15, 31, 47, 600]) {
        final tag = smartTag('id-$minutes', counter(minutes));
        final at = start.add(Duration(minutes: minutes));
        expect(resolveDevice(tag, at, [first]), 'tag-a', reason: '$minutes');
      }
    });

    test('a SmartTag set up at another time is another tracker', () {
      final first = seen(
        'tag-a',
        0,
        kind: TrackerKind.smartTag,
        id: 'id-0',
        aging: counter(0),
      );
      for (final setUpAgo in [960, 1040, 500000]) {
        final other = smartTag('other', counter(30, setUpAgo: setUpAgo));
        final at = start.add(const Duration(minutes: 30));
        expect(resolveDevice(other, at, [first]), 'other', reason: '$setUpAgo');
      }
    });

    test('other kinds are never linked by a counter', () {
      final first = seen('tag-a', 0, id: 'id-0', aging: counter(0));
      final tile = Tracker(
        kind: TrackerKind.tile,
        owner: OwnerState.unknown,
        address: 'E0:00:00:00:00:01',
        rssi: -60,
        aging: counter(15),
      );
      expect(
        resolveDevice(tile, start.add(const Duration(minutes: 15)), [first]),
        tile.id,
      );
    });
  });

  for (final (name, next, last, expected) in [
    (
      'the same place a minute later',
      seen('1', 1, place: 0),
      seen('1', 0, place: 0),
      true,
    ),
    ('no location twice in a row', seen('1', 1), seen('1', 0), true),
    ('another place', seen('1', 1, place: 1), seen('1', 0, place: 0), false),
    (
      'ten minutes later',
      seen('1', 10, place: 0),
      seen('1', 0, place: 0),
      false,
    ),
    ('a first location', seen('1', 1, place: 0), seen('1', 0), false),
  ]) {
    test('isRepeat is $expected for $name', () {
      expect(isRepeat(next, last), expected);
    });
  }
}
