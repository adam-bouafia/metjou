import 'dart:async';
import 'dart:math';

import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/services/alert_countdown.dart';
import 'package:metjou/core/services/background_services.dart';
import 'package:metjou/core/services/fall_detector.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _enabledKey = "fallDetection";

/// Countdown after a detected fall, even when the normal countdown is
/// shorter or off: falls give the most false alarms.
const fallCountdownSeconds = 15;

/// Listens to the accelerometer (50 Hz) while the app runs, including in
/// the background while Safe Shake keeps it alive.
abstract final class FallDetection {
  static StreamSubscription<AccelerometerEvent>? _subscription;
  static final _detector = FallDetector();
  static final _clock = Stopwatch();

  static Future<bool> isEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_enabledKey) ?? false;

  static Future<void> setEnabled(bool enabled) async {
    await (await SharedPreferences.getInstance()).setBool(_enabledKey, enabled);
    enabled ? _start() : _stop();
  }

  static Future<void> apply() async {
    if (await isEnabled()) _start();
  }

  static void _start() {
    if (_subscription != null) return;
    _detector.reset();
    _clock
      ..reset()
      ..start();
    _subscription =
        accelerometerEventStream(
          samplingPeriod: SensorInterval.gameInterval,
        ).listen((e) {
          final g = sqrt(e.x * e.x + e.y * e.y + e.z * e.z) / 9.80665;
          if (_detector.add(g, _clock.elapsed)) {
            AlertCountdown.start(
              _sendFallAlert,
              minimumSeconds: fallCountdownSeconds,
            );
          }
        });
  }

  static void _stop() {
    _subscription?.cancel();
    _subscription = null;
    _clock.stop();
  }

  static Future<void> _sendFallAlert() async {
    final l10n = await backgroundLocalizations();
    if (await BackgroundServices.sendSosAlert(l10n.smsFall) > 0) {
      await (await SharedPreferences.getInstance()).setBool("alerted", true);
    }
  }
}
