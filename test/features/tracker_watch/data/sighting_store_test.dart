import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/features/tracker_watch/data/sighting_store.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';

Sighting sighting(String device, DateTime at, {double? lat, int? aging}) =>
    Sighting(
      device: device,
      kind: TrackerKind.airTag,
      at: at,
      address: 'AA:BB:CC:DD:EE:FF',
      rssi: -61,
      lat: lat,
      lon: lat == null ? null : 4.9,
      aging: aging,
    );

void main() {
  late Directory dir;
  late SightingStore store;
  final noon = DateTime(2026, 10, 5, 12);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('sightings_test');
    // A folder that does not exist yet, as on first use.
    store = SightingStore.at(Directory('${dir.path}/trackers'));
  });

  tearDown(() => dir.delete(recursive: true));

  test('is empty before anything was seen', () async {
    expect(await store.load(), isEmpty);
    await store.prune(noon);
    await store.clear();
  });

  test('a sighting comes back as it was stored', () async {
    await store.append([sighting('a', noon, lat: 52.37, aging: 66051)]);
    final s = (await store.load()).single;
    expect(s.device, 'a');
    expect(s.kind, TrackerKind.airTag);
    expect(s.at, noon);
    expect(s.address, 'AA:BB:CC:DD:EE:FF');
    expect(s.rssi, -61);
    expect((s.lat, s.lon), (52.37, 4.9));
    expect(s.aging, 66051);
    expect(s.hasPlace, isTrue);
  });

  test('a sighting without a location has no place', () async {
    await store.append([sighting('a', noon)]);
    final s = (await store.load()).single;
    expect((s.lat, s.lon, s.aging), (null, null, null));
    expect(s.hasPlace, isFalse);
  });

  test('appending keeps earlier sightings, loaded oldest first', () async {
    await store.append([sighting('b', noon)]);
    await store.append([
      sighting('c', noon.add(const Duration(minutes: 5))),
      sighting('a', noon.subtract(const Duration(minutes: 5))),
    ]);
    expect((await store.load()).map((s) => s.device), ['a', 'b', 'c']);
  });

  test('load can start from a moment', () async {
    await store.append([
      sighting('old', noon.subtract(const Duration(hours: 30))),
      sighting('edge', noon.subtract(const Duration(hours: 24))),
      sighting('new', noon),
    ]);
    final since = noon.subtract(const Duration(hours: 24));
    expect((await store.load(since: since)).map((s) => s.device), [
      'edge',
      'new',
    ]);
  });

  test('damaged lines and unknown tracker kinds are skipped', () async {
    await store.append([sighting('a', noon)]);
    final file = File('${store.folder.path}/sightings.jsonl');
    await file.writeAsString(
      'not json\n{"d":"x","k":"futureTag","t":1,"a":"A","r":-1}\n\n',
      mode: FileMode.append,
    );
    await store.append([sighting('b', noon)]);
    expect((await store.load()).map((s) => s.device), ['a', 'b']);
  });

  test('prune removes only what is older', () async {
    await store.append([
      sighting('old', noon.subtract(const Duration(days: 20))),
      sighting('new', noon),
    ]);
    await store.prune(noon.subtract(const Duration(days: 14)));
    expect((await store.load()).map((s) => s.device), ['new']);
    // The file still takes new sightings after the rewrite.
    await store.append([sighting('later', noon.add(const Duration(hours: 1)))]);
    expect(await store.load(), hasLength(2));
  });

  test('clear removes everything', () async {
    await store.append([sighting('a', noon)]);
    await store.clear();
    expect(await store.load(), isEmpty);
  });
}
