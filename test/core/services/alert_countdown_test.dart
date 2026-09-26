import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/core/services/alert_countdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sends right away when the countdown is off', (tester) async {
    SharedPreferences.setMockInitialValues({countdownSecondsKey: 0});
    var sent = 0;
    await AlertCountdown.start(() async => sent++);
    expect(sent, 1);
    expect(AlertCountdown.remaining.value, isNull);
  });

  testWidgets('sends after the countdown ends', (tester) async {
    SharedPreferences.setMockInitialValues({countdownSecondsKey: 3});
    var sent = 0;
    await AlertCountdown.start(() async => sent++);
    expect(AlertCountdown.remaining.value, 3);
    await tester.pump(const Duration(seconds: 2));
    expect(sent, 0);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(sent, 1);
    expect(AlertCountdown.remaining.value, isNull);
  });

  testWidgets('Cancel stops the alert', (tester) async {
    SharedPreferences.setMockInitialValues({countdownSecondsKey: 3});
    var sent = 0;
    await AlertCountdown.start(() async => sent++);
    await tester.pump(const Duration(seconds: 1));
    await AlertCountdown.cancel();
    await tester.pump(const Duration(seconds: 5));
    expect(sent, 0);
  });

  testWidgets('a Cancel from the notification stops the alert', (tester) async {
    SharedPreferences.setMockInitialValues({countdownSecondsKey: 3});
    var sent = 0;
    await AlertCountdown.start(() async => sent++);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(countdownCancelledKey, 1);
    await tester.pump(const Duration(seconds: 5));
    expect(sent, 0);
    expect(AlertCountdown.remaining.value, isNull);
  });

  testWidgets('a minimum overrides a disabled countdown', (tester) async {
    SharedPreferences.setMockInitialValues({countdownSecondsKey: 0});
    var sent = 0;
    await AlertCountdown.start(() async => sent++, minimumSeconds: 15);
    expect(AlertCountdown.remaining.value, 15);
    await tester.pump(const Duration(seconds: 14));
    expect(sent, 0);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(sent, 1);
  });
}
