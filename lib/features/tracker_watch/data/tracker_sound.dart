import 'package:flutter/services.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tracker_scan/tracker_scan.dart';

enum SoundResult { playing, unsupported, unreachable, permissionDenied }

// The sound commands below are the ones the open-source AirGuard app sends
// (TU Darmstadt, Apache-2.0).

/// First-generation AirTag: one byte, and the tag hangs up when it is done.
const _airTag = GattWrite(
  service: '7dfc9000-7d1c-4951-86aa-8d9728f8d66c',
  characteristic: '7dfc9001-7d1c-4951-86aa-8d9728f8d66c',
  value: [0xAF],
);

// "Detecting Unwanted Location Trackers", the standard Apple and Google
// share: opcode 0x0300 (low byte first) starts the sound.
const _dultService = '15190001-12f4-c226-88ed-2ac5579f2a85';
const _dultCharacteristic = '8e0c0001-1d68-fb92-bf61-48377421680e';
const _dult = GattWrite(
  service: _dultService,
  characteristic: _dultCharacteristic,
  value: [0x00, 0x03],
  subscribe: true,
);
const _google = GattWrite(
  service: _dultService,
  characteristic: _dultCharacteristic,
  value: [0x00, 0x03],
);

/// Other brands' tags on Apple's Find My network.
final _findMy = GattWrite(
  service: uuid16(0xFD44),
  characteristic: '4f860003-943b-49ef-bed4-2f730304427a',
  value: const [0x01, 0x00, 0x03],
  subscribe: true,
);

final _pebblebee = GattWrite(
  service: uuid16(0xFA25),
  characteristic: uuid16(0x2C02),
  value: const [0x01],
  noResponse: true,
);

/// What to try to make a tracker of [kind] play a sound, most likely first.
/// Empty for families that only ring for their owner.
List<GattWrite> soundCommands(TrackerKind kind) => switch (kind) {
  TrackerKind.airTag => [_airTag, _dult, _findMy],
  TrackerKind.findMy => [_dult, _findMy, _airTag],
  TrackerKind.airPods => [_findMy, _dult, _airTag],
  TrackerKind.googleFindMy => const [_google],
  TrackerKind.pebblebee => [_pebblebee],
  TrackerKind.smartTag || TrackerKind.tile || TrackerKind.chipolo => const [],
};

bool canPlaySound(TrackerKind kind) => soundCommands(kind).isNotEmpty;

/// Makes a nearby tracker play a sound so it can be found.
abstract final class TrackerSound {
  /// Asks for the permission to connect, then sends the sound command.
  static Future<SoundResult> play(TrackerKind kind, String address) async {
    if (!canPlaySound(kind)) return SoundResult.unsupported;
    if (!await Permission.bluetoothConnect.request().isGranted) {
      return SoundResult.permissionDenied;
    }
    return send(kind, address);
  }

  /// Connects to the tracker at [address] and sends its sound command.
  static Future<SoundResult> send(TrackerKind kind, String address) async {
    final commands = soundCommands(kind);
    if (commands.isEmpty) return SoundResult.unsupported;
    try {
      await TrackerScan.writeGatt(address: address, writes: commands);
      return SoundResult.playing;
    } on PlatformException catch (e) {
      return switch (e.code) {
        // Still connected from the last request: that sound is playing.
        'busy' => SoundResult.playing,
        'not_supported' => SoundResult.unsupported,
        'permission' => SoundResult.permissionDenied,
        _ => SoundResult.unreachable,
      };
    }
  }
}
