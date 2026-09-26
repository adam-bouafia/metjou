import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/services/background_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const checkInTask = "check-in-missed";
const checkInDeadlineKey = "checkin_deadline";
const _sentKey = "checkin_sent";

/// Formats a deadline for notifications, which have no BuildContext.
typedef TimeFormatter = String Function(DateTime time);

/// "Alert my contacts if I don't check in in time." An in-app timer fires
/// at the deadline; a Workmanager task one minute later is the backup for
/// when Android stopped the app. Whichever runs first sends, only once.
abstract final class CheckInService {
  /// The running deadline, or null.
  static final ValueNotifier<DateTime?> deadline = ValueNotifier(null);

  static Timer? _timer;

  static Future<void> start(Duration within, TimeFormatter format) async {
    await _schedule(DateTime.now().add(within), format);
  }

  static Future<void> extend(Duration by, TimeFormatter format) async {
    final current = deadline.value;
    if (current == null) return;
    await _schedule(current.add(by), format);
  }

  static Future<void> _schedule(DateTime at, TimeFormatter format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(checkInDeadlineKey, at.millisecondsSinceEpoch);
    await prefs.setBool(_sentKey, false);
    deadline.value = at;
    _startTimer(at);
    await Workmanager().registerOneOffTask(
      checkInTask,
      checkInTask,
      initialDelay: at.difference(DateTime.now()) + const Duration(minutes: 1),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
    final l10n = await backgroundLocalizations();
    await _quietly(
      () => BackgroundServices.showCheckInNotification(
        title: l10n.checkInBefore(format(at)),
        body: l10n.checkInNotifBody,
        safeLabel: l10n.checkInSafe,
      ),
    );
  }

  static void _startTimer(DateTime at) {
    _timer?.cancel();
    final wait = at.difference(DateTime.now());
    _timer = Timer(wait.isNegative ? Duration.zero : wait, fireIfMissed);
  }

  /// The user is safe: stop everything.
  static Future<void> checkIn() async {
    _timer?.cancel();
    _timer = null;
    deadline.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(checkInDeadlineKey);
    await _quietly(() => Workmanager().cancelByUniqueName(checkInTask));
    await _quietly(BackgroundServices.cancelCheckInNotification);
  }

  /// Sends the alert when the deadline passed without a check-in. Safe to
  /// call from the timer, the Workmanager task and at app start.
  static Future<void> fireIfMissed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final ms = prefs.getInt(checkInDeadlineKey);
    if (ms == null || (prefs.getBool(_sentKey) ?? false)) return;
    final due = DateTime.fromMillisecondsSinceEpoch(ms);
    if (DateTime.now().isBefore(due)) return;
    await prefs.setBool(_sentKey, true);
    await prefs.remove(checkInDeadlineKey);
    _timer?.cancel();
    _timer = null;
    deadline.value = null;
    final l10n = await backgroundLocalizations();
    await BackgroundServices.sendSosAlert(l10n.smsCheckInMissed);
    await _quietly(
      () => BackgroundServices.showCheckInNotification(
        title: l10n.checkInAlerted,
        body: l10n.smsCheckInMissed,
        safeLabel: l10n.checkInSafe,
      ),
    );
  }

  /// At app start: pick up a running deadline, or send if it was missed
  /// while the app was closed. A check-in from the notification clears the
  /// stored deadline, which also stops a running timer.
  static Future<void> resume() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final ms = prefs.getInt(checkInDeadlineKey);
    if (ms == null) {
      _timer?.cancel();
      deadline.value = null;
      return;
    }
    final at = DateTime.fromMillisecondsSinceEpoch(ms);
    if (DateTime.now().isBefore(at)) {
      deadline.value = at;
      _startTimer(at);
    } else {
      await fireIfMissed();
    }
  }

  /// Notification and scheduler failures must never block an alert.
  static Future<void> _quietly(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      debugPrint("check-in: $e");
    }
  }
}
