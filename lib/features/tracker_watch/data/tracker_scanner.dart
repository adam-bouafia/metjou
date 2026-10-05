import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tracker_scan/tracker_scan.dart';

/// Why a scan could not run.
enum ScanBlocker {
  unsupported,
  bluetoothOff,
  permissionDenied,
  locationOff,
  failed,
}

/// What a scan found, or what stopped it.
class ScanOutcome {
  const ScanOutcome.found(this.trackers) : blocker = null;

  const ScanOutcome.blocked(ScanBlocker this.blocker) : trackers = const [];

  final List<Tracker> trackers;
  final ScanBlocker? blocker;
}

/// How long one manual scan listens: long enough to hear tags that only
/// advertise every few seconds more than once.
const manualScanDuration = Duration(seconds: 10);

/// Scans for trackers nearby.
abstract final class TrackerScanner {
  /// Checks everything a scan needs, asking for permissions, then scans.
  static Future<ScanOutcome> run() async {
    final blocker = await check();
    return blocker == null ? scan() : ScanOutcome.blocked(blocker);
  }

  /// What stops a scan right now, or null when it can run.
  static Future<ScanBlocker?> check() async {
    switch (await TrackerScan.state()) {
      case BluetoothState.unsupported:
        return ScanBlocker.unsupported;
      case BluetoothState.off:
        return ScanBlocker.bluetoothOff;
      case BluetoothState.on:
    }
    final statuses = await [
      Permission.bluetoothScan,
      Permission.location,
    ].request();
    if (statuses.values.any((status) => !status.isGranted)) {
      return ScanBlocker.permissionDenied;
    }
    // Android hands over no Bluetooth scan results while location is off.
    if (!await Geolocator.isLocationServiceEnabled()) {
      return ScanBlocker.locationOff;
    }
    return null;
  }

  /// One scan; trackers away from their owner come first.
  static Future<ScanOutcome> scan({
    Duration duration = manualScanDuration,
  }) async {
    try {
      final adverts = await TrackerScan.scan(
        filters: trackerFilters,
        duration: duration,
      );
      return ScanOutcome.found(trackersIn(adverts));
    } on PlatformException catch (e) {
      return ScanOutcome.blocked(switch (e.code) {
        // Location set to "approximate" also ends up here.
        'permission' => ScanBlocker.permissionDenied,
        'bluetooth_off' => ScanBlocker.bluetoothOff,
        _ => ScanBlocker.failed,
      });
    }
  }
}
