import 'package:metjou/core/services/device.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = "discreet";

/// Disguises MetJou for people whose phone may be checked by someone else:
/// calculator icon and name, neutral notifications hidden on the lock
/// screen, and no preview in the recent apps screen.
abstract final class DiscreetMode {
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getBool(_prefsKey) ?? false;
  }

  static Future<void> setEnabled(bool enabled) async {
    await (await SharedPreferences.getInstance()).setBool(_prefsKey, enabled);
    await Device.setDiscreet(enabled);
    await Device.setSecure(enabled);
  }

  /// Called at app start; the launcher alias itself persists on its own.
  static Future<void> apply() async {
    if (await isEnabled()) await Device.setSecure(true);
  }
}
