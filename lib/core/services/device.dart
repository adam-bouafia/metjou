import 'package:flutter/services.dart';

/// Actions that can start the app from the Quick Settings tile, the home
/// screen widget or an app shortcut.
abstract final class LaunchAction {
  static const sos = 'sos';
  static const fakeCall = 'fake_call';
  static const siren = 'siren';
}

/// Native device features from MainActivity (see MainActivity.kt).
abstract final class Device {
  static const _channel = MethodChannel('metjou/device');

  static void Function(String action)? _onLaunchAction;

  /// Calls [handler] for actions that arrive while the app is running, and
  /// once for the action that started the app, if any.
  static Future<void> listenForLaunchActions(
    void Function(String action) handler,
  ) async {
    _onLaunchAction = handler;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'launchAction') {
        _onLaunchAction?.call(call.arguments as String);
      }
    });
    final initial = await _channel.invokeMethod<String>('takeLaunchAction');
    if (initial != null) handler(initial);
  }

  /// Turns the flashlight on or off. Returns false when there is none.
  static Future<bool> setTorch(bool on) async =>
      await _channel.invokeMethod<bool>('setTorch', {'on': on}) ?? false;

  /// Sets media volume to maximum; [restoreVolume] puts it back.
  static Future<void> boostVolume() => _channel.invokeMethod('boostVolume');

  static Future<void> restoreVolume() => _channel.invokeMethod('restoreVolume');

  /// Plays the phone's own ringtone in a loop, for the fake call.
  static Future<void> startRingtone() => _channel.invokeMethod('startRingtone');

  static Future<void> stopRingtone() => _channel.invokeMethod('stopRingtone');

  /// Shows the disguised launcher icon instead of MetJou's.
  static Future<void> setDiscreet(bool enabled) =>
      _channel.invokeMethod('setDiscreet', {'enabled': enabled});

  /// Blanks the app's preview in the recent apps screen (FLAG_SECURE).
  static Future<void> setSecure(bool enabled) =>
      _channel.invokeMethod('setSecure', {'enabled': enabled});
}
