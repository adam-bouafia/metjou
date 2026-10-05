import 'package:flutter/services.dart';

/// Full 128-bit form of a 16-bit Bluetooth UUID, as Android reports it.
String uuid16(int short) =>
    '0000${short.toRadixString(16).padLeft(4, '0')}-0000-1000-8000-00805f9b34fb';

enum BluetoothState { unsupported, off, on }

/// Which adverts a scan returns. Android applies filters in the Bluetooth
/// chip, and only filtered scans keep running while the screen is off.
///
/// With [data] and [mask], an advert matches when its bytes equal [data] in
/// every bit that is set in [mask]. Both must have the same length.
class BleFilter {
  /// Manufacturer data of the company with Bluetooth id [manufacturerId].
  const BleFilter.manufacturerData(
    int this.manufacturerId, {
    this.data,
    this.mask,
  }) : serviceData = null,
       serviceUuid = null;

  /// Service data for the service with UUID [serviceData].
  const BleFilter.serviceData(String this.serviceData, {this.data, this.mask})
    : manufacturerId = null,
      serviceUuid = null;

  /// Adverts that list the service with UUID [serviceUuid].
  const BleFilter.serviceUuid(String this.serviceUuid)
    : manufacturerId = null,
      serviceData = null,
      data = null,
      mask = null;

  final int? manufacturerId;
  final String? serviceData;
  final String? serviceUuid;
  final List<int>? data;
  final List<int>? mask;

  Map<String, Object?> toMap() => {
    'manufacturerId': manufacturerId,
    'serviceData': serviceData,
    'serviceUuid': serviceUuid,
    'data': data == null ? null : Uint8List.fromList(data!),
    'mask': mask == null ? null : Uint8List.fromList(mask!),
  };
}

/// One device seen during a scan, with its strongest signal.
class BleAdvert {
  const BleAdvert({
    required this.address,
    required this.rssi,
    this.name,
    this.manufacturerData = const {},
    this.serviceData = const {},
    this.serviceUuids = const [],
  });

  factory BleAdvert.fromMap(Map<Object?, Object?> map) => BleAdvert(
    address: map['address']! as String,
    rssi: map['rssi']! as int,
    name: map['name'] as String?,
    manufacturerData: (map['manufacturerData'] as Map? ?? const {})
        .cast<int, Uint8List>(),
    serviceData: (map['serviceData'] as Map? ?? const {})
        .cast<String, Uint8List>(),
    serviceUuids: (map['serviceUuids'] as List? ?? const []).cast<String>(),
  );

  /// Bluetooth address. Trackers change it regularly, so it only identifies
  /// a device for a limited time.
  final String address;

  /// Signal strength in dBm; closer to 0 is stronger.
  final int rssi;

  /// Name from the advert, when the device sends one.
  final String? name;

  /// Manufacturer data by Bluetooth company id, without the id bytes.
  final Map<int, Uint8List> manufacturerData;

  /// Service data by service UUID (128-bit form, see [uuid16]).
  final Map<String, Uint8List> serviceData;

  final List<String> serviceUuids;
}

/// Bluetooth LE scanning through the Android plugin.
abstract final class TrackerScan {
  static const _channel = MethodChannel('metjou/tracker_scan');

  static Future<BluetoothState> state() async =>
      BluetoothState.values.byName(await _channel.invokeMethod('state'));

  /// Scans for [duration] and returns each matching device once.
  ///
  /// [lowPower] scans in short windows to save battery, for background use.
  ///
  /// Throws a [PlatformException] with code `permission` (Bluetooth scan or
  /// precise location not granted), `bluetooth_off`, `busy` (a scan is
  /// already running) or `scan_failed`.
  static Future<List<BleAdvert>> scan({
    required List<BleFilter> filters,
    Duration duration = const Duration(seconds: 8),
    bool lowPower = false,
  }) async {
    final found = await _channel.invokeListMethod<Map<Object?, Object?>>(
      'scan',
      {
        'filters': [for (final f in filters) f.toMap()],
        'durationMs': duration.inMilliseconds,
        'lowPower': lowPower,
      },
    );
    return [for (final map in found ?? const []) BleAdvert.fromMap(map)];
  }
}
