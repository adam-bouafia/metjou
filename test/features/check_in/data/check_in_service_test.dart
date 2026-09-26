import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/features/check_in/data/check_in_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('nothing happens before the deadline', () async {
    final future = DateTime.now().add(const Duration(minutes: 5));
    SharedPreferences.setMockInitialValues({
      checkInDeadlineKey: future.millisecondsSinceEpoch,
    });
    await CheckInService.fireIfMissed();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(checkInDeadlineKey), isNotNull);
  });

  test('a missed deadline sends once and clears the timer', () async {
    final past = DateTime.now().subtract(const Duration(minutes: 1));
    SharedPreferences.setMockInitialValues({
      checkInDeadlineKey: past.millisecondsSinceEpoch,
    });
    await CheckInService.fireIfMissed();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(checkInDeadlineKey), isNull);
    expect(prefs.getBool('checkin_sent'), isTrue);
    expect(CheckInService.deadline.value, isNull);
  });

  test('no deadline means no alert', () async {
    SharedPreferences.setMockInitialValues({});
    await CheckInService.fireIfMissed();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('checkin_sent'), isNull);
  });
}
