import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:tracker_scan/tracker_scan.dart';

Uint8List bytes(List<int> head, [int length = 0]) => Uint8List.fromList([
  ...head,
  for (var i = head.length; i < length; i++) 0xAB,
]);

BleAdvert apple(List<int> head, {int length = 27, int rssi = -70}) => BleAdvert(
  address: 'AA:AA:AA:AA:AA:AA',
  rssi: rssi,
  manufacturerData: {0x4C: bytes(head, length)},
);

BleAdvert service(
  int uuid,
  List<int> data, {
  String address = 'BB:BB:BB:BB:BB:BB',
  int rssi = -70,
}) => BleAdvert(
  address: address,
  rssi: rssi,
  serviceUuids: [uuid16(uuid)],
  serviceData: {uuid16(uuid): bytes(data)},
);

void main() {
  final cases = <(String, BleAdvert, TrackerKind, OwnerState)>[
    (
      'AirTag away from its owner',
      apple([0x12, 0x19, 0x10]),
      TrackerKind.airTag,
      OwnerState.away,
    ),
    (
      'AirTag near its owner, any battery level',
      apple([0x12, 0x02, 0x50, 0x00], length: 4),
      TrackerKind.airTag,
      OwnerState.near,
    ),
    (
      'Find My tag of another brand',
      apple([0x12, 0x19, 0x20]),
      TrackerKind.findMy,
      OwnerState.away,
    ),
    (
      'AirPods',
      apple([0x12, 0x19, 0x30]),
      TrackerKind.airPods,
      OwnerState.away,
    ),
    (
      'SmartTag overmature offline',
      service(0xFD5A, [0x13, 0x01]),
      TrackerKind.smartTag,
      OwnerState.away,
    ),
    (
      'SmartTag offline',
      service(0xFD5A, [0x12, 0x01]),
      TrackerKind.smartTag,
      OwnerState.away,
    ),
    (
      'SmartTag that just lost its owner',
      service(0xFD5A, [0x11, 0x01]),
      TrackerKind.smartTag,
      OwnerState.near,
    ),
    (
      'SmartTag connected',
      service(0xFD5A, [0x15, 0x01]),
      TrackerKind.smartTag,
      OwnerState.near,
    ),
    (
      'Google tag in unwanted tracking mode',
      service(0xFEAA, [0x41, 0x99]),
      TrackerKind.googleFindMy,
      OwnerState.away,
    ),
    (
      'Google tag recently with its owner',
      service(0xFEAA, [0x40, 0x99]),
      TrackerKind.googleFindMy,
      OwnerState.near,
    ),
    (
      'Tile',
      service(0xFEED, [0x02, 0x00, 0x77]),
      TrackerKind.tile,
      OwnerState.unknown,
    ),
    (
      'Chipolo with old firmware, away',
      service(0xFE33, [0x00, 0x01], address: 'D8:00:00:00:00:01'),
      TrackerKind.chipolo,
      OwnerState.away,
    ),
    (
      'Chipolo with old firmware, near',
      service(0xFE33, [0x00, 0x00], address: 'C1:00:00:00:00:01'),
      TrackerKind.chipolo,
      OwnerState.near,
    ),
    (
      'Chipolo with new firmware',
      service(0xFE33, [0x00, 0x01], address: 'D9:00:00:00:00:01'),
      TrackerKind.chipolo,
      OwnerState.unknown,
    ),
    (
      'Pebblebee',
      service(0xFA25, [0x00]),
      TrackerKind.pebblebee,
      OwnerState.unknown,
    ),
  ];

  for (final (name, advert, kind, owner) in cases) {
    test('recognises $name', () {
      final tracker = identifyTracker(advert)!;
      expect(tracker.kind, kind);
      expect(tracker.owner, owner);
      expect(tracker.address, advert.address);
      expect(tracker.rssi, advert.rssi);
    });
  }

  final others = <(String, BleAdvert)>[
    ('an iPhone or Mac in Find My mode', apple([0x12, 0x19, 0x00])),
    ('another Apple advert type', apple([0x10, 0x05, 0x10], length: 7)),
    ('a truncated Apple advert', apple([0x12, 0x19], length: 2)),
    ('an Eddystone URL beacon', service(0xFEAA, [0x10, 0x03])),
    ('other Samsung service data', service(0xFD5A, [0x23])),
    ('a Tile that is not activated', service(0xFEED, [0x01, 0x00])),
    ('a heart rate sensor', service(0x180D, [0x00])),
    ('an empty advert', const BleAdvert(address: 'CC', rssi: -50)),
  ];

  for (final (name, advert) in others) {
    test('ignores $name', () => expect(identifyTracker(advert), isNull));
  }

  for (final (rssi, proximity) in [
    (-40, Proximity.veryClose),
    (-60, Proximity.veryClose),
    (-61, Proximity.close),
    (-75, Proximity.close),
    (-76, Proximity.far),
  ]) {
    test('signal $rssi dBm is ${proximity.name}', () {
      final tracker = identifyTracker(apple([0x12, 0x19, 0x10], rssi: rssi))!;
      expect(tracker.proximity, proximity);
    });
  }

  test('there is a scan filter for every tracker family', () {
    // Android only hands over adverts that match a filter, so a family
    // without one would never be seen.
    expect(trackerFilters, hasLength(6));
    expect(trackerFilters.first.manufacturerId, 0x4C);
    expect(trackerFilters.map((f) => f.serviceData ?? f.serviceUuid).nonNulls, [
      uuid16(0xFD5A),
      uuid16(0xFEAA),
      uuid16(0xFEED),
      uuid16(0xFE33),
      uuid16(0xFA25),
    ]);
  });

  test('trackersIn puts away first, then unknown, then by signal', () {
    final found = trackersIn([
      apple([0x12, 0x02, 0x10, 0x00], length: 4, rssi: -40),
      service(0xFEED, [0x02, 0x00], rssi: -50),
      service(0x180D, [0x00]),
      apple([0x12, 0x19, 0x10], rssi: -80),
      service(0xFD5A, [0x13], rssi: -55),
    ]);
    expect(
      [for (final t in found) (t.kind, t.owner, t.rssi)],
      [
        (TrackerKind.smartTag, OwnerState.away, -55),
        (TrackerKind.airTag, OwnerState.away, -80),
        (TrackerKind.tile, OwnerState.unknown, -50),
        (TrackerKind.airTag, OwnerState.near, -40),
      ],
    );
  });
}
