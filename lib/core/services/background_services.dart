import 'dart:async';
import 'dart:io';

import 'package:another_telephony/telephony.dart';
import 'package:audio_background_record/audio_background_record.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/services/low_battery.dart';
import 'package:metjou/features/check_in/data/check_in_service.dart';
import 'package:metjou/features/contacts/data/sos_contacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundServices {
  BackgroundServices._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static const String _notificationIcon = "ic_bg_service_small";

  static const String smsNotificationChannelID = "BG_SMS_SEND_SERVICE";
  static const int smsNotificationID = 888;
  static const _smsNotificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      smsNotificationChannelID,
      smsNotificationChannelID,
      channelDescription: 'Safe Shake status',
      icon: _notificationIcon,
    ),
  );

  static const String audioRecordNotificationChannelID =
      "BG_AUDIO_RECORD_SERVICE";
  static const int audioRecordNotificationID = 555;
  static const _audioRecordNotificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      audioRecordNotificationChannelID,
      audioRecordNotificationChannelID,
      channelDescription: 'Background audio recording status',
      icon: _notificationIcon,
    ),
  );

  static Future<void> init({
    void Function(NotificationResponse response)? onResponse,
  }) async {
    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_notificationIcon),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: onResponse,
      onDidReceiveBackgroundNotificationResponse:
          onNotificationResponseInBackground,
    );
  }

  // Countdown before an alert, with a Cancel action.

  static const cancelAlertAction = "cancel_alert";
  static const int _countdownNotificationID = 777;

  static Future<void> showCountdownNotification({
    required String title,
    required String body,
    required String cancelLabel,
  }) => _notifications.show(
    id: _countdownNotificationID,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        "SOS_COUNTDOWN",
        "SOS countdown",
        channelDescription: 'Time to cancel an alert',
        icon: _notificationIcon,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        onlyAlertOnce: true,
        ongoing: true,
        actions: [
          AndroidNotificationAction(
            cancelAlertAction,
            cancelLabel,
            cancelNotification: true,
            showsUserInterface: true,
          ),
        ],
      ),
    ),
  );

  // Check-in timer, with an "I'm safe" action.

  static const checkInAction = "check_in";
  static const int _checkInNotificationID = 778;

  static Future<void> showCheckInNotification({
    required String title,
    required String body,
    required String safeLabel,
  }) => _notifications.show(
    id: _checkInNotificationID,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        "CHECK_IN",
        "Check-in timer",
        channelDescription: 'Deadline to check in',
        icon: _notificationIcon,
        ongoing: true,
        onlyAlertOnce: true,
        actions: [
          AndroidNotificationAction(
            checkInAction,
            safeLabel,
            cancelNotification: true,
            showsUserInterface: true,
          ),
        ],
      ),
    ),
  );

  static Future<void> cancelCheckInNotification() =>
      _notifications.cancel(id: _checkInNotificationID);

  // Fake call that rings while the app is in the background.

  static const fakeCallPayload = "fake_call";
  static const int _fakeCallNotificationID = 779;

  static Future<void> showFakeCallNotification({
    required String title,
    required String body,
  }) => _notifications.show(
    id: _fakeCallNotificationID,
    title: title,
    body: body,
    payload: fakeCallPayload,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        "FAKE_CALL",
        "Fake call",
        channelDescription: 'Incoming fake call',
        icon: _notificationIcon,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.call,
        autoCancel: true,
      ),
    ),
  );

  // Medical ID on the lock screen: silent, persistent and public, so first
  // responders can read it without unlocking.

  static const int _medicalIdNotificationID = 780;

  static Future<void> showMedicalIdNotification({
    required String title,
    required String body,
  }) => _notifications.show(
    id: _medicalIdNotificationID,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        "MEDICAL_ID",
        "Medical ID",
        channelDescription: 'Health details on the lock screen',
        icon: _notificationIcon,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        playSound: false,
        enableVibration: false,
        visibility: NotificationVisibility.public,
        styleInformation: BigTextStyleInformation(body),
      ),
    ),
  );

  static Future<void> cancelMedicalIdNotification() =>
      _notifications.cancel(id: _medicalIdNotificationID);

  static Future<void> cancelCountdownNotification() =>
      _notifications.cancel(id: _countdownNotificationID);

  /// Discreet mode: status notifications are not shown.
  /// Loaded at app start and updated when the setting changes.
  static bool discreet = false;

  static Future<void> _show(
    int id,
    String title,
    String body,
    NotificationDetails details,
  ) async {
    // Discreet mode skips status notifications: Android shows the real
    // app name in every notification header, which a disguise cannot hide.
    if (discreet) return;
    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  static Future<void> showSmsNotification({
    required String title,
    required String content,
  }) => _show(smsNotificationID, title, content, _smsNotificationDetails);

  static Future<void> cancelSmsNotification() =>
      _notifications.cancel(id: smsNotificationID);

  static Future<void> showAudioRecordNotification({
    required String title,
    required String content,
  }) => _show(
    audioRecordNotificationID,
    title,
    content,
    _audioRecordNotificationDetails,
  );

  static Future<void> cancelAudioRecordNotification() =>
      _notifications.cancel(id: audioRecordNotificationID);

  // Location

  static Position? _lastPosition;
  static String _foregroundNotificationText = "MetJou";
  static StreamSubscription<Position>? _positionSubscription;

  /// Keeps a foreground service with a location stream running while Safe
  /// Shake is on. It keeps a recent fix ready for alerts and keeps the
  /// process (and with it the shake listener) alive in the background.
  static void startLocationUpdates({String? notificationText}) {
    if (notificationText != null) {
      _foregroundNotificationText = notificationText;
    }
    _positionSubscription ??=
        Geolocator.getPositionStream(
          locationSettings: defaultTargetPlatform == TargetPlatform.android
              ? AndroidSettings(
                  accuracy: LocationAccuracy.high,
                  distanceFilter: 20,
                  foregroundNotificationConfig: ForegroundNotificationConfig(
                    notificationTitle: discreet ? "" : "Safe Shake",
                    notificationText: discreet
                        ? ""
                        : _foregroundNotificationText,
                    notificationIcon: const AndroidResource(
                      name: _notificationIcon,
                    ),
                    setOngoing: true,
                  ),
                )
              : AppleSettings(
                  accuracy: LocationAccuracy.high,
                  distanceFilter: 20,
                  allowBackgroundLocationUpdates: true,
                  showBackgroundLocationIndicator: true,
                ),
        ).listen(
          (position) => _lastPosition = position,
          onError: (Object e) => debugPrint("location stream: $e"),
        );
  }

  /// Stops background location unless Safe Shake or a repeating Get home
  /// safe still needs it.
  static Future<void> releaseLocationUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final safeShake = prefs.getBool("smsSend") ?? false;
    final repeating =
        (prefs.getBool("getHomeSafe") ?? false) &&
        prefs.getInt("ghs_interval_min") != null;
    if (!safeShake && !repeating) await stopLocationUpdates();
  }

  static Future<void> stopLocationUpdates() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Best effort Google Maps link for the current position. Returns an empty
  /// string when no fix is available; an alert must never wait on GPS.
  static Future<String> currentLocationLink() async {
    Position? position = _lastPosition;
    final isFresh =
        position != null &&
        DateTime.now().difference(position.timestamp) <
            const Duration(minutes: 2);
    if (!isFresh) {
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (e) {
        debugPrint("current position: $e");
        position ??= await Geolocator.getLastKnownPosition();
      }
    }
    if (position == null) return "";
    return "https://maps.google.com/?q=${position.latitude},${position.longitude}";
  }

  // SMS

  /// Sends [message] plus a location link (or 'location not available').
  static Future<bool> sendLocationSms(String to, String message) async {
    final l10n = await backgroundLocalizations();
    final link = await currentLocationLink();
    return _sendSms(
      to,
      "$message\n${link.isEmpty ? l10n.smsNoLocation : link}",
    );
  }

  static Future<bool> _sendSms(String to, String message) async {
    try {
      await Telephony.instance.sendSms(
        to: to,
        message: message,
        isMultipart: true,
      );
      return true;
    } catch (e) {
      debugPrint("sms to $to failed: $e");
      return false;
    }
  }

  /// Sends [message] plus a location link to every SOS contact.
  /// Returns the number of messages handed to the SMS service.
  static Future<int> sendSosAlert(
    String message, {
    bool withLocation = true,
  }) async {
    final contacts = await loadSosContacts();
    if (contacts.isEmpty) return 0;
    var text = message;
    if (withLocation) {
      final link = await currentLocationLink();
      text = link.isEmpty
          ? "$message ${(await backgroundLocalizations()).smsNoLocation}"
          : "$message\n$link";
    }
    var sent = 0;
    for (final contact in contacts) {
      if (await _sendSms(contact.phone, text)) sent++;
    }
    return sent;
  }

  /// Shake handler: alerts all SOS contacts and posts a notification.
  static Future<void> sendSms() async {
    final l10n = await backgroundLocalizations();
    final sent = await sendSosAlert(l10n.smsShake);
    if (sent > 0) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("alerted", true);
    }
    await showSmsNotification(
      title: l10n.notifShakeTitle,
      content: sent > 0 ? l10n.notifShakeSent : l10n.notifShakeNoContacts,
    );
  }

  // Audio recording

  /// Recording status from the plugin: 1 started, 2 stopped (message is
  /// where the file was saved), 0 error (message is the error).
  static Future<void> audioRecordCallBack(int status, String? message) async {
    final l10n = await backgroundLocalizations();
    switch (status) {
      case 1:
        await showAudioRecordNotification(
          title: l10n.notifRecording,
          content: l10n.notifRecordingStarted,
        );
      case 2:
        await showAudioRecordNotification(
          title: l10n.notifRecording,
          content: message == null
              ? l10n.notifRecordingStopped
              : l10n.notifRecordingSaved(message),
        );
      case 0:
        debugPrint("audio record error: $message");
        await showAudioRecordNotification(
          title: l10n.notifRecording,
          content: l10n.notifRecordingFailed,
        );
    }
  }

  static Future<void> setAudioRecording(bool enabled) async {
    final recorder = AudioBackgroundRecord.getInstance();
    if (enabled) {
      // App-private storage: no storage permission, removed on uninstall.
      final dir = Directory(
        "${(await getApplicationDocumentsDirectory()).path}/recordings",
      );
      await dir.create(recursive: true);
      await recorder.configure(savetoDirectory: dir.path);
      await recorder.startRecordingService();
      recorder.setOnRecordStatusChangedCallback(audioRecordCallBack);
      final l10n = await backgroundLocalizations();
      await showAudioRecordNotification(
        title: l10n.notifRecording,
        content: l10n.notifRecordingReady,
      );
    } else {
      await recorder.stopRecordingService();
      await cancelAudioRecordNotification();
    }
  }

  static Future<void> setSafeShake(bool enabled) async {
    if (enabled) {
      final l10n = await backgroundLocalizations();
      await showSmsNotification(
        title: l10n.notifShakeTitle,
        content: l10n.notifShakeBody,
      );
      _foregroundNotificationText = l10n.notifShakeBody;
      startLocationUpdates();
    } else {
      await cancelSmsNotification();
      await releaseLocationUpdates();
    }
  }

  /// Restores the services the user switched on in a previous session.
  static Future<void> checkService() async {
    final prefs = await SharedPreferences.getInstance();
    await setAudioRecording(prefs.getBool("bgRecord") ?? false);
    await setSafeShake(prefs.getBool("smsSend") ?? false);
  }
}

/// Workmanager task name for a Get home safe message at a chosen time.
const getHomeSafeOnceTask = "get-home-safe-once";

/// Runs Workmanager tasks in a background isolate: the one-off Get home
/// safe message at the time the user chose and the low battery check.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == lowBatteryTask) {
      await LowBatteryAlert.check();
      return true;
    }
    if (task == checkInTask) {
      await CheckInService.fireIfMissed();
      return true;
    }
    final contact = inputData?['contact'] as String?;
    if (contact == null) return true;
    final l10n = await backgroundLocalizations();
    await BackgroundServices.sendLocationSms(contact, l10n.smsGetHomeSafe);
    if (task == getHomeSafeOnceTask) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("getHomeSafe", false);
    }
    return true;
  });
}

/// Notification actions tapped while the app's Flutter engine is not in
/// the foreground. Marks the countdown as cancelled; the countdown checks
/// the flag every second.
@pragma('vm:entry-point')
void onNotificationResponseInBackground(NotificationResponse response) async {
  if (response.actionId == BackgroundServices.checkInAction) {
    // Clearing the deadline stops the timer and the backup task.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("checkin_deadline");
  }
  if (response.actionId == BackgroundServices.cancelAlertAction) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      "countdownCancelledAt",
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
