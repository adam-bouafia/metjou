import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/features/tracker_watch/data/tracker_scanner.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:tracker_scan/tracker_scan.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('metjou/tracker_scan');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  MethodCall? scanCall;

  void answer(Object? Function(MethodCall call) handler) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'scan') scanCall = call;
      return handler(call);
    });
  }

  setUp(() => scanCall = null);
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('scan returns the trackers, away from their owner first', () async {
    answer(
      (_) => [
        {
          'address': 'AA',
          'rssi': -50,
          'manufacturerData': {
            0x4C: Uint8List.fromList([0x12, 0x02, 0x10, 0x00]),
          },
        },
        {
          'address': 'BB',
          'rssi': -80,
          'serviceData': {
            uuid16(0xFD5A): Uint8List.fromList([0x13]),
          },
        },
        {'address': 'CC', 'rssi': -40},
      ],
    );
    final outcome = await TrackerScanner.scan();
    expect(outcome.blocker, isNull);
    expect(
      [for (final t in outcome.trackers) (t.address, t.kind, t.owner)],
      [
        ('BB', TrackerKind.smartTag, OwnerState.away),
        ('AA', TrackerKind.airTag, OwnerState.near),
      ],
    );
  });

  test('scan asks Android for every tracker family, for ten seconds', () async {
    answer((_) => <Object?>[]);
    await TrackerScanner.scan();
    final args = scanCall!.arguments as Map;
    expect(args['filters'], hasLength(trackerFilters.length));
    expect(args['durationMs'], 10000);
    expect(args['lowPower'], isFalse);
  });

  for (final (code, blocker) in [
    ('permission', ScanBlocker.permissionDenied),
    ('bluetooth_off', ScanBlocker.bluetoothOff),
    ('scan_failed', ScanBlocker.failed),
    ('busy', ScanBlocker.failed),
  ]) {
    test('scan reports $code as ${blocker.name}', () async {
      answer((_) => throw PlatformException(code: code));
      final outcome = await TrackerScanner.scan();
      expect(outcome.blocker, blocker);
      expect(outcome.trackers, isEmpty);
    });
  }

  for (final (state, blocker) in [
    ('unsupported', ScanBlocker.unsupported),
    ('off', ScanBlocker.bluetoothOff),
  ]) {
    test('run stops before scanning when Bluetooth is $state', () async {
      answer((_) => state);
      expect((await TrackerScanner.run()).blocker, blocker);
      expect(scanCall, isNull);
    });
  }
}
