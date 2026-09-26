import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/core/services/low_battery.dart';

void main() {
  for (final (level, charging, sent, expected) in [
    (10, false, false, LowBatteryAction.send),
    (5, false, false, LowBatteryAction.send),
    (5, false, true, LowBatteryAction.none),
    (11, false, false, LowBatteryAction.none),
    (15, false, true, LowBatteryAction.none),
    (20, false, true, LowBatteryAction.reset),
    (8, true, true, LowBatteryAction.reset),
    (8, true, false, LowBatteryAction.none),
  ]) {
    test('level $level, charging $charging, sent $sent -> $expected', () {
      expect(
        decideLowBattery(level: level, charging: charging, alreadySent: sent),
        expected,
      );
    });
  }
}
