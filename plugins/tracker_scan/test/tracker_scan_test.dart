import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_scan/tracker_scan.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('metjou/tracker_scan');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];

  void answer(Object? Function(MethodCall call) handler) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return handler(call);
    });
  }

  setUp(calls.clear);
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('uuid16 gives the 128-bit Bluetooth form', () {
    expect(uuid16(0xFD5A), '0000fd5a-0000-1000-8000-00805f9b34fb');
    expect(uuid16(0x00AA), '000000aa-0000-1000-8000-00805f9b34fb');
  });

  for (final state in BluetoothState.values) {
    test('state reads ${state.name}', () async {
      answer((_) => state.name);
      expect(await TrackerScan.state(), state);
    });
  }

  test('scan sends filters as bytes and the duration', () async {
    answer((_) => <Object?>[]);
    await TrackerScan.scan(
      filters: [
        const BleFilter.manufacturerData(0x4C, data: [0x12], mask: [0xFF]),
        BleFilter.serviceData(uuid16(0xFEED)),
        BleFilter.serviceUuid(uuid16(0xFE33)),
      ],
      duration: const Duration(seconds: 3),
      lowPower: true,
    );
    final args = calls.single.arguments as Map;
    expect(args['durationMs'], 3000);
    expect(args['lowPower'], isTrue);
    final filters = (args['filters'] as List).cast<Map>();
    expect(filters[0]['manufacturerId'], 0x4C);
    expect(filters[0]['data'], isA<Uint8List>());
    expect(filters[0]['data'], [0x12]);
    expect(filters[0]['mask'], [0xFF]);
    expect(filters[1]['serviceData'], uuid16(0xFEED));
    expect(filters[1]['data'], isNull);
    expect(filters[2]['serviceUuid'], uuid16(0xFE33));
  });

  test('scan decodes adverts', () async {
    answer(
      (_) => [
        {
          'address': 'AA:BB:CC:DD:EE:FF',
          'rssi': -58,
          'name': null,
          'manufacturerData': {
            0x4C: Uint8List.fromList([0x12, 0x19, 0x10]),
          },
          'serviceData': {
            uuid16(0xFD5A): Uint8List.fromList([0x13]),
          },
          'serviceUuids': [uuid16(0xFD5A)],
        },
      ],
    );
    final advert = (await TrackerScan.scan(filters: const [])).single;
    expect(advert.address, 'AA:BB:CC:DD:EE:FF');
    expect(advert.rssi, -58);
    expect(advert.name, isNull);
    expect(advert.manufacturerData[0x4C], [0x12, 0x19, 0x10]);
    expect(advert.serviceData[uuid16(0xFD5A)], [0x13]);
    expect(advert.serviceUuids, [uuid16(0xFD5A)]);
  });

  test('scan returns nothing for an empty result', () async {
    answer((_) => null);
    expect(await TrackerScan.scan(filters: const []), isEmpty);
  });

  test('live streams adverts and sends the filters', () async {
    const liveChannel = EventChannel('metjou/tracker_scan/live');
    Object? listenArguments;
    var cancelled = false;
    messenger.setMockStreamHandler(
      liveChannel,
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          listenArguments = arguments;
          events.success({'address': 'AA', 'rssi': -70});
          events.success({'address': 'AA', 'rssi': -55});
        },
        onCancel: (_) => cancelled = true,
      ),
    );
    addTearDown(() => messenger.setMockStreamHandler(liveChannel, null));

    final rssi = <int>[];
    final subscription = TrackerScan.live(
      filters: [BleFilter.serviceUuid(uuid16(0xFE33))],
    ).listen((advert) => rssi.add(advert.rssi));
    await pumpEventQueue();
    expect(rssi, [-70, -55]);
    final filters = ((listenArguments! as Map)['filters'] as List).cast<Map>();
    expect(filters.single['serviceUuid'], uuid16(0xFE33));

    await subscription.cancel();
    await pumpEventQueue();
    expect(cancelled, isTrue);
  });

  test(
    'writeGatt sends the writes as bytes and returns the one used',
    () async {
      answer((_) => 1);
      final used = await TrackerScan.writeGatt(
        address: 'AA:BB:CC:DD:EE:FF',
        writes: [
          GattWrite(
            service: uuid16(0xFD44),
            characteristic: uuid16(0x2C02),
            value: const [0x01, 0x00, 0x03],
            subscribe: true,
          ),
          GattWrite(
            service: uuid16(0xFA25),
            characteristic: uuid16(0x2C02),
            value: const [0x01],
            noResponse: true,
          ),
        ],
        hold: const Duration(seconds: 2),
        timeout: const Duration(seconds: 5),
      );
      expect(used, 1);
      final call = calls.single;
      expect(call.method, 'writeGatt');
      final args = call.arguments as Map;
      expect(args['address'], 'AA:BB:CC:DD:EE:FF');
      expect(args['holdMs'], 2000);
      expect(args['timeoutMs'], 5000);
      final writes = (args['writes'] as List).cast<Map>();
      expect(writes[0]['service'], uuid16(0xFD44));
      expect(writes[0]['value'], isA<Uint8List>());
      expect(writes[0]['value'], [0x01, 0x00, 0x03]);
      expect(writes[0]['subscribe'], isTrue);
      expect(writes[0]['noResponse'], isFalse);
      expect(writes[1]['noResponse'], isTrue);
    },
  );

  test('scan passes platform errors on', () async {
    answer((_) => throw PlatformException(code: 'bluetooth_off'));
    expect(
      TrackerScan.scan(filters: const []),
      throwsA(
        isA<PlatformException>().having((e) => e.code, 'code', 'bluetooth_off'),
      ),
    );
  });
}
