import 'package:audio_background_record/audio_background_record.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('audio_background_record');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return call.method == 'isRecording' ? true : null;
    });
  });

  test('configure sends directory and duration under the native keys', () async {
    await AudioBackgroundRecord.getInstance()
        .configure(savetoDirectory: '/data/rec', maxDurationInMillis: 60000);

    expect(calls.single.method, 'setConfiguration');
    expect(calls.single.arguments,
        {'directory': '/data/rec', 'duration': 60000, 'notificationText': null});
  });

  test('isRecording returns the native result', () async {
    expect(await AudioBackgroundRecord.getInstance().isRecording(), isTrue);
  });
}
