import 'package:battery_plus/battery_plus.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/services/background_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const lowBatteryTask = "low-battery-check";
const _enabledKey = "lowBatteryEnabled";
const _sentKey = "lowBatterySent";

/// Send at or below this level...
const lowBatteryLevel = 10;

/// ...and only again after the phone was charged above this level.
const rechargedLevel = 20;

enum LowBatteryAction { send, reset, none }

/// What to do for a battery reading; pure so it can be tested.
LowBatteryAction decideLowBattery({
  required int level,
  required bool charging,
  required bool alreadySent,
}) {
  if (charging || level >= rechargedLevel) {
    return alreadySent ? LowBatteryAction.reset : LowBatteryAction.none;
  }
  if (level <= lowBatteryLevel && !alreadySent) return LowBatteryAction.send;
  return LowBatteryAction.none;
}

/// Texts the SOS contacts the last location once when the battery is
/// nearly empty, from a Workmanager task every 15 minutes.
abstract final class LowBatteryAlert {
  static Future<bool> isEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_enabledKey) ?? false;

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    await prefs.remove(_sentKey);
    if (enabled) {
      await Workmanager().registerPeriodicTask(
        lowBatteryTask,
        lowBatteryTask,
        frequency: const Duration(minutes: 15),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
    } else {
      await Workmanager().cancelByUniqueName(lowBatteryTask);
    }
  }

  /// Runs in the Workmanager isolate.
  static Future<void> check() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (!(prefs.getBool(_enabledKey) ?? false)) return;
    final battery = Battery();
    final level = await battery.batteryLevel;
    final state = await battery.batteryState;
    final action = decideLowBattery(
      level: level,
      charging: state == BatteryState.charging || state == BatteryState.full,
      alreadySent: prefs.getBool(_sentKey) ?? false,
    );
    switch (action) {
      case LowBatteryAction.send:
        final l10n = await backgroundLocalizations();
        if (await BackgroundServices.sendSosAlert(l10n.smsLowBattery(level)) >
            0) {
          await prefs.setBool(_sentKey, true);
        }
      case LowBatteryAction.reset:
        await prefs.remove(_sentKey);
      case LowBatteryAction.none:
        break;
    }
  }
}
