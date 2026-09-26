import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/services/background_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

const countdownSecondsKey = "countdownSeconds";
const defaultCountdownSeconds = 5;

/// Set by the notification's Cancel action, which may run in a background
/// isolate; the countdown checks it every second.
const countdownCancelledKey = "countdownCancelledAt";

/// A few seconds to cancel an alert that was not sent on purpose, such as
/// one triggered by shaking. Shown as a full-screen overlay in the app and
/// as a notification with a Cancel button outside it.
abstract final class AlertCountdown {
  /// Seconds left, or null when no countdown is running.
  static final ValueNotifier<int?> remaining = ValueNotifier(null);

  static Timer? _timer;
  static Future<void> Function()? _onFire;

  static Future<void> start(Future<void> Function() onFire) async {
    if (_timer != null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final seconds =
        prefs.getInt(countdownSecondsKey) ?? defaultCountdownSeconds;
    if (seconds <= 0) {
      await onFire();
      return;
    }
    await prefs.remove(countdownCancelledKey);
    _onFire = onFire;
    remaining.value = seconds;
    await _announce();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _step());
  }

  static Future<void> _step() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (prefs.containsKey(countdownCancelledKey)) {
      await cancel();
      return;
    }
    final left = (remaining.value ?? 1) - 1;
    if (left > 0) {
      remaining.value = left;
      await _announce();
      return;
    }
    final fire = _onFire;
    _reset();
    await _quietly(BackgroundServices.cancelCountdownNotification);
    await fire?.call();
  }

  /// Vibrates and updates the notification. Failures here must never stop
  /// the alert itself, so they are only logged.
  static Future<void> _announce() async {
    try {
      if (await Vibration.hasVibrator()) Vibration.vibrate(duration: 150);
      final l10n = await backgroundLocalizations();
      await BackgroundServices.showCountdownNotification(
        title: l10n.countdownTitle(remaining.value ?? 0),
        body: l10n.countdownBody,
        cancelLabel: l10n.cancel,
      );
    } catch (e) {
      debugPrint("countdown notification failed: $e");
    }
  }

  static Future<void> cancel() async {
    if (_timer == null) return;
    _reset();
    await _quietly(BackgroundServices.cancelCountdownNotification);
    // Fire and forget: nothing waits for the toast.
    unawaited(
      _quietly(() async {
        final l10n = await backgroundLocalizations();
        return Fluttertoast.showToast(msg: l10n.alertCancelled);
      }),
    );
  }

  static Future<void> _quietly(Future<Object?> Function() action) async {
    try {
      await action();
    } catch (e) {
      debugPrint("countdown: $e");
    }
  }

  static void _reset() {
    _timer?.cancel();
    _timer = null;
    _onFire = null;
    remaining.value = null;
  }
}
