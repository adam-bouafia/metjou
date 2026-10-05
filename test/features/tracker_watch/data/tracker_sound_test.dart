import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:metjou/features/tracker_watch/data/tracker_sound.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('metjou/tracker_scan');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  MethodCall? call;

  void answer(Object? Function() handler) {
    messenger.setMockMethodCallHandler(channel, (c) async {
      call = c;
      return handler();
    });
  }

  setUp(() => call = null);
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  for (final (kind, expected) in [
    (TrackerKind.airTag, true),
    (TrackerKind.findMy, true),
    (TrackerKind.airPods, true),
    (TrackerKind.googleFindMy, true),
    (TrackerKind.pebblebee, true),
    (TrackerKind.smartTag, false),
    (TrackerKind.tile, false),
    (TrackerKind.chipolo, false),
  ]) {
    test('${kind.name} can play a sound: $expected', () {
      expect(canPlaySound(kind), expected);
    });
  }

  test('an AirTag is first asked the AirTag way, then the shared standard', () {
    final commands = soundCommands(TrackerKind.airTag);
    expect(commands.first.service, startsWith('7dfc9000'));
    expect(commands.first.value, [0xAF]);
    expect(commands.first.subscribe, isFalse);
    expect(commands[1].service, startsWith('15190001'));
    expect(commands[1].value, [0x00, 0x03]);
    expect(commands[1].subscribe, isTrue);
  });

  test('send connects to the address with the commands of that kind', () async {
    answer(() => 0);
    expect(
      await TrackerSound.send(TrackerKind.pebblebee, 'AA:BB'),
      SoundResult.playing,
    );
    final args = call!.arguments as Map;
    expect(call!.method, 'writeGatt');
    expect(args['address'], 'AA:BB');
    final write = (args['writes'] as List).single as Map;
    expect(write['service'], '0000fa25-0000-1000-8000-00805f9b34fb');
    expect(write['characteristic'], '00002c02-0000-1000-8000-00805f9b34fb');
    expect(write['value'], [0x01]);
    expect(write['noResponse'], isTrue);
  });

  test('send does not connect to a tracker that cannot ring', () async {
    answer(() => 0);
    expect(
      await TrackerSound.send(TrackerKind.tile, 'AA:BB'),
      SoundResult.unsupported,
    );
    expect(call, isNull);
  });

  for (final (code, result) in [
    ('busy', SoundResult.playing),
    ('not_supported', SoundResult.unsupported),
    ('permission', SoundResult.permissionDenied),
    ('connect_failed', SoundResult.unreachable),
    ('timeout', SoundResult.unreachable),
    ('write_failed', SoundResult.unreachable),
    ('bluetooth_off', SoundResult.unreachable),
  ]) {
    test('send reports $code as ${result.name}', () async {
      answer(() => throw PlatformException(code: code));
      expect(await TrackerSound.send(TrackerKind.airTag, 'AA:BB'), result);
    });
  }
}
