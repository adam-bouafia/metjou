import 'package:tracker_scan/tracker_scan.dart';

/// Kinds of location tracker MetJou recognises.
enum TrackerKind {
  airTag,

  /// Another brand's tag on Apple's Find My network.
  findMy,
  airPods,
  smartTag,

  /// A tag on Google's Find My Device network.
  googleFindMy,
  tile,
  chipolo,
  pebblebee,
}

/// Where a tracker's owner is, as far as its advert tells.
enum OwnerState {
  /// With its owner, or separated only a short while ago.
  near,

  /// Away from its owner for longer. A planted tracker is in this state.
  away,

  /// This kind of tracker does not say.
  unknown,
}

/// Rough distance, from signal strength. Walls, bags and bodies weaken the
/// signal, so this is a hint and not a measurement.
enum Proximity { veryClose, close, far }

/// A tracker seen in one scan.
class Tracker {
  const Tracker({
    required this.kind,
    required this.owner,
    required this.address,
    required this.rssi,
    String? id,
    this.aging,
  }) : id = id ?? address;

  final TrackerKind kind;
  final OwnerState owner;

  /// Bluetooth address, needed to connect to it. Trackers change it
  /// regularly.
  final String address;

  /// Signal strength in dBm; closer to 0 is stronger.
  final int rssi;

  /// What identifies this tracker until it changes its address: the address
  /// itself, or for a SmartTag the privacy ID inside its advert.
  final String id;

  /// SmartTag only: a counter that goes up by one every 15 minutes. It
  /// links the same tag across address changes, see `isSameTracker`.
  final int? aging;

  Proximity get proximity => rssi >= -60
      ? Proximity.veryClose
      : rssi >= -75
      ? Proximity.close
      : Proximity.far;
}

/// Short code to tell trackers apart on screen: the last four hex digits
/// of an id, such as `A2:3F`.
String deviceCode(String id) {
  final hex = id.replaceAll(RegExp('[^0-9a-fA-F]'), '').toUpperCase();
  if (hex.length < 4) return id.toUpperCase();
  final end = hex.substring(hex.length - 4);
  return '${end.substring(0, 2)}:${end.substring(2)}';
}

const _apple = 0x004C;
final _samsung = uuid16(0xFD5A);
final _google = uuid16(0xFEAA);
final _tile = uuid16(0xFEED);
final _chipolo = uuid16(0xFE33);
final _pebblebee = uuid16(0xFA25);

/// Scan filters for every tracker family. The byte patterns here and the
/// decoding in [identifyTracker] follow the open-source AirGuard app
/// (TU Darmstadt, Apache-2.0, github.com/seemoo-lab/AirGuard).
final trackerFilters = <BleFilter>[
  // Apple Find My adverts start with type 0x12.
  const BleFilter.manufacturerData(_apple, data: [0x12], mask: [0xFF]),
  // Samsung SmartTag: the top five bits of the first byte are 00010.
  BleFilter.serviceData(_samsung, data: [0x10], mask: [0xF8]),
  // Google Find My Device network: frame type 0x40 or 0x41. Other frame
  // types on this UUID are plain Eddystone beacons.
  BleFilter.serviceData(_google, data: [0x40], mask: [0xFE]),
  BleFilter.serviceData(_tile, data: [0x02, 0x00], mask: [0xFF, 0xFF]),
  BleFilter.serviceUuid(_chipolo),
  BleFilter.serviceUuid(_pebblebee),
];

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

Tracker? _appleFindMy(BleAdvert advert) {
  final data = advert.manufacturerData[_apple];
  if (data == null || data.length < 3 || data[0] != 0x12) return null;
  // Bits 4-5 of the status byte give the device type. Type 0 is a phone,
  // tablet or laptop, which is not a tag.
  final kind = switch ((data[2] & 0x30) >> 4) {
    1 => TrackerKind.airTag,
    2 => TrackerKind.findMy,
    3 => TrackerKind.airPods,
    _ => null,
  };
  if (kind == null) return null;
  // Away from its owner a tag sends the long advert (25 bytes, 0x19) that
  // other people's phones pick up; near its owner it sends a short one.
  return Tracker(
    kind: kind,
    owner: data[1] == 0x19 ? OwnerState.away : OwnerState.near,
    address: advert.address,
    rssi: advert.rssi,
  );
}

Tracker? _samsungSmartTag(BleAdvert advert) {
  final data = advert.serviceData[_samsung];
  if (data == null || data.isEmpty || (data[0] & 0xF8) != 0x10) return null;
  // Low three bits: 010 "offline" and 011 "overmature offline" mean out of
  // reach of the owner; 001 has only just lost contact, the rest is connected.
  final state = data[0] & 0x07;
  // A full advert carries the aging counter (bytes 1-3, low byte first) and
  // the privacy ID (bytes 4-11).
  final full = data.length >= 12;
  return Tracker(
    kind: TrackerKind.smartTag,
    owner: state == 2 || state == 3 ? OwnerState.away : OwnerState.near,
    address: advert.address,
    rssi: advert.rssi,
    id: full ? _hex(data.sublist(4, 12)) : null,
    aging: full ? data[3] << 16 | data[2] << 8 | data[1] : null,
  );
}

Tracker? _googleFindMy(BleAdvert advert) {
  final data = advert.serviceData[_google];
  if (data == null || data.isEmpty || (data[0] & 0xFE) != 0x40) return null;
  // Frame 0x41 is sent once the tag has been away from its owner for hours.
  return Tracker(
    kind: TrackerKind.googleFindMy,
    owner: data[0] == 0x41 ? OwnerState.away : OwnerState.near,
    address: advert.address,
    rssi: advert.rssi,
  );
}

Tracker? _tileTag(BleAdvert advert) {
  final data = advert.serviceData[_tile];
  if (data == null || data.length < 2 || data[0] != 0x02 || data[1] != 0x00) {
    return null;
  }
  return Tracker(
    kind: TrackerKind.tile,
    owner: OwnerState.unknown,
    address: advert.address,
    rssi: advert.rssi,
  );
}

Tracker? _chipoloTag(BleAdvert advert) {
  if (!advert.serviceUuids.contains(_chipolo)) return null;
  final data = advert.serviceData[_chipolo];
  // Up to firmware D8 (the first byte of the address) the second byte has
  // an "away from the owner" bit; newer firmware dropped it.
  final oldFirmware =
      advert.address.length >= 2 &&
      advert.address.substring(0, 2).toUpperCase().compareTo('D8') <= 0;
  final owner = data == null || data.length < 2 || !oldFirmware
      ? OwnerState.unknown
      : data[1] & 1 == 1
      ? OwnerState.away
      : OwnerState.near;
  return Tracker(
    kind: TrackerKind.chipolo,
    owner: owner,
    address: advert.address,
    rssi: advert.rssi,
  );
}

Tracker? _pebblebeeTag(BleAdvert advert) =>
    advert.serviceUuids.contains(_pebblebee)
    ? Tracker(
        kind: TrackerKind.pebblebee,
        owner: OwnerState.unknown,
        address: advert.address,
        rssi: advert.rssi,
      )
    : null;

/// The tracker behind [advert], or null when it is something else.
Tracker? identifyTracker(BleAdvert advert) =>
    _appleFindMy(advert) ??
    _samsungSmartTag(advert) ??
    _googleFindMy(advert) ??
    _tileTag(advert) ??
    _chipoloTag(advert) ??
    _pebblebeeTag(advert);

/// The trackers among [adverts]: those away from their owner first, then
/// the ones that do not say, then by signal strength.
List<Tracker> trackersIn(Iterable<BleAdvert> adverts) {
  const order = {OwnerState.away: 0, OwnerState.unknown: 1, OwnerState.near: 2};
  return adverts.map(identifyTracker).nonNulls.toList()..sort((a, b) {
    final byOwner = order[a.owner]!.compareTo(order[b.owner]!);
    return byOwner != 0 ? byOwner : b.rssi.compareTo(a.rssi);
  });
}
