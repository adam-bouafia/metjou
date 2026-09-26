import 'dart:async';

import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/services/background_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

/// When Get home safe sends the user's location to the chosen contact.
sealed class GetHomeSafeSchedule {
  const GetHomeSafeSchedule();
}

/// Right away, then every [interval] until switched off.
class RepeatEvery extends GetHomeSafeSchedule {
  const RepeatEvery(this.interval);

  final Duration interval;
}

/// One message at [at].
class SendOnceAt extends GetHomeSafeSchedule {
  const SendOnceAt(this.at);

  final DateTime at;
}

const _kActive = "getHomeSafe";
const _kContact = "ghs_contact";
const _kIntervalMin = "ghs_interval_min";
const _kAt = "ghs_at";

/// Periodic task name used by the first version (every 15 minutes).
const _legacyTask = "3";

class GetHomeSafeState {
  const GetHomeSafeState(this.contact, this.schedule);

  final String contact;
  final GetHomeSafeSchedule schedule;
}

/// Repeating messages run on a timer in the app, kept alive by the
/// foreground location service; Workmanager cannot repeat faster than every
/// 15 minutes. A one-off message at a set time is a Workmanager task, so it
/// also runs when the app is closed (Android may delay it a few minutes).
class GetHomeSafeService {
  GetHomeSafeService._();

  static Timer? _timer;

  static Future<GetHomeSafeState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final contact = prefs.getString(_kContact);
    if (!(prefs.getBool(_kActive) ?? false) || contact == null) return null;
    final minutes = prefs.getInt(_kIntervalMin);
    final at = DateTime.tryParse(prefs.getString(_kAt) ?? "");
    if (minutes != null) {
      return GetHomeSafeState(contact, RepeatEvery(Duration(minutes: minutes)));
    }
    if (at != null) return GetHomeSafeState(contact, SendOnceAt(at));
    return null;
  }

  static Future<void> start(
    String contact,
    GetHomeSafeSchedule schedule,
  ) async {
    await stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kActive, true);
    await prefs.setString(_kContact, contact);
    switch (schedule) {
      case RepeatEvery(:final interval):
        await prefs.setInt(_kIntervalMin, interval.inMinutes);
        await _startRepeating(contact, interval);
        await _send(contact);
      case SendOnceAt(:final at):
        await prefs.setString(_kAt, at.toIso8601String());
        await Workmanager().registerOneOffTask(
          getHomeSafeOnceTask,
          getHomeSafeOnceTask,
          initialDelay: at.difference(DateTime.now()),
          inputData: {"contact": contact},
          existingWorkPolicy: ExistingWorkPolicy.replace,
        );
    }
  }

  static Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    await Workmanager().cancelByUniqueName(getHomeSafeOnceTask);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kActive, false);
    await prefs.remove(_kIntervalMin);
    await prefs.remove(_kAt);
    await BackgroundServices.releaseLocationUpdates();
  }

  /// Called at app start: drops the old 15-minute task and restarts a
  /// repeating schedule that was on when the app was closed.
  static Future<void> resume() async {
    await Workmanager().cancelByUniqueName(_legacyTask);
    final state = await load();
    if (state case GetHomeSafeState(
      :final contact,
      schedule: RepeatEvery(:final interval),
    )) {
      await _startRepeating(contact, interval);
    }
  }

  static Future<void> _startRepeating(String contact, Duration interval) async {
    final l10n = await backgroundLocalizations();
    BackgroundServices.startLocationUpdates(
      notificationText: l10n.getHomeSafeOn,
    );
    _timer = Timer.periodic(interval, (_) => _send(contact));
  }

  static Future<void> _send(String contact) async {
    final l10n = await backgroundLocalizations();
    await BackgroundServices.sendLocationSms(contact, l10n.smsGetHomeSafe);
  }
}
