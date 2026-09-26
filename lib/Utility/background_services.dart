import 'dart:async';
import 'dart:io';

import 'package:another_telephony/telephony.dart';
import 'package:audio_background_record/audio_background_record.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:metjou/Utility/app_locale.dart';
import 'package:metjou/Utility/sos_contacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundServices {
  BackgroundServices._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static const simplePeriodicTask = "simplePeriodicTask";
  static const String _notificationIcon = "ic_bg_service_small";

  static const String smsNotificationChannelID = "BG_SMS_SEND_SERVICE";
  static const int smsNotificationID = 888;
  static const _smsNotificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
          smsNotificationChannelID, smsNotificationChannelID,
          channelDescription: 'Safe Shake status',
          icon: _notificationIcon));

  static const String audioRecordNotificationChannelID = "BG_AUDIO_RECORD_SERVICE";
  static const int audioRecordNotificationID = 555;
  static const _audioRecordNotificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
          audioRecordNotificationChannelID, audioRecordNotificationChannelID,
          channelDescription: 'Background audio recording status',
          icon: _notificationIcon));

  static Future<void> init() async {
    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_notificationIcon),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  static Future<void> showSmsNotification({required String title, required String content}) =>
      _notifications.show(
          id: smsNotificationID,
          title: title,
          body: content,
          notificationDetails: _smsNotificationDetails);

  static Future<void> cancelSmsNotification() =>
      _notifications.cancel(id: smsNotificationID);

  static Future<void> showAudioRecordNotification({required String title, required String content}) =>
      _notifications.show(
          id: audioRecordNotificationID,
          title: title,
          body: content,
          notificationDetails: _audioRecordNotificationDetails);

  static Future<void> cancelAudioRecordNotification() =>
      _notifications.cancel(id: audioRecordNotificationID);

  // Location

  static Position? _lastPosition;
  static String _foregroundNotificationText = "MetJou";
  static StreamSubscription<Position>? _positionSubscription;

  /// Keeps a foreground service with a location stream running while Safe
  /// Shake is on. It keeps a recent fix ready for alerts and keeps the
  /// process (and with it the shake listener) alive in the background.
  static void startLocationUpdates() {
    _positionSubscription ??= Geolocator.getPositionStream(
      locationSettings: defaultTargetPlatform == TargetPlatform.android
          ? AndroidSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 20,
              foregroundNotificationConfig: ForegroundNotificationConfig(
                notificationTitle: "Safe Shake",
                notificationText: _foregroundNotificationText,
                notificationIcon: const AndroidResource(name: _notificationIcon),
                setOngoing: true,
              ),
            )
          : AppleSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 20,
              allowBackgroundLocationUpdates: true,
              showBackgroundLocationIndicator: true,
            ),
    ).listen((position) => _lastPosition = position,
        onError: (Object e) => debugPrint("location stream: $e"));
  }

  static Future<void> stopLocationUpdates() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Best effort Google Maps link for the current position. Returns an empty
  /// string when no fix is available; an alert must never wait on GPS.
  static Future<String> currentLocationLink() async {
    Position? position = _lastPosition;
    final isFresh = position != null &&
        DateTime.now().difference(position.timestamp) < const Duration(minutes: 2);
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

  static Future<bool> _sendSms(String to, String message) async {
    try {
      await Telephony.instance.sendSms(to: to, message: message, isMultipart: true);
      return true;
    } catch (e) {
      debugPrint("sms to $to failed: $e");
      return false;
    }
  }

  /// Sends [message] plus a location link to every SOS contact.
  /// Returns the number of messages handed to the SMS service.
  static Future<int> sendSosAlert(String message, {bool withLocation = true}) async {
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

  static Future<void> audioRecordCallBack(int status, String? errorMsg) async {
    final l10n = await backgroundLocalizations();
    switch (status) {
      case 1: // recording started
        showAudioRecordNotification(
            title: l10n.notifRecording, content: l10n.notifRecordingStarted);
      case 2: // recording stopped
        showAudioRecordNotification(
            title: l10n.notifRecording, content: l10n.notifRecordingStopped);
      case 0: // recording error
        debugPrint("audio record error: $errorMsg");
    }
  }

  static Future<void> setAudioRecording(bool enabled) async {
    final recorder = AudioBackgroundRecord.getInstance();
    if (enabled) {
      // App-private storage: no storage permission, removed on uninstall.
      final dir = Directory("${(await getApplicationDocumentsDirectory()).path}/recordings");
      await dir.create(recursive: true);
      await recorder.configure(savetoDirectory: dir.path);
      await recorder.startRecordingService();
      recorder.setOnRecordStatusChangedCallback(audioRecordCallBack);
      final l10n = await backgroundLocalizations();
      await showAudioRecordNotification(
          title: l10n.notifRecording, content: l10n.notifRecordingReady);
    } else {
      await recorder.stopRecordingService();
      await cancelAudioRecordNotification();
    }
  }

  static Future<void> setSafeShake(bool enabled) async {
    if (enabled) {
      final l10n = await backgroundLocalizations();
      await showSmsNotification(title: l10n.notifShakeTitle, content: l10n.notifShakeBody);
      _foregroundNotificationText = l10n.notifShakeBody;
      startLocationUpdates();
    } else {
      await cancelSmsNotification();
      await stopLocationUpdates();
    }
  }

  /// Restores the services the user switched on in a previous session.
  static Future<void> checkService() async {
    final prefs = await SharedPreferences.getInstance();
    await setAudioRecording(prefs.getBool("bgRecord") ?? false);
    await setSafeShake(prefs.getBool("smsSend") ?? false);
  }
}

/// Get-Home Safe: periodic Workmanager task that texts the current location
/// to the contact chosen when the mode was switched on.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final contact = inputData?['contact'] as String?;
    if (contact == null) return true;
    final l10n = await backgroundLocalizations();
    final link = await BackgroundServices.currentLocationLink();
    await BackgroundServices._sendSms(contact,
        "${l10n.smsGetHomeSafe}\n${link.isEmpty ? l10n.smsNoLocation : link}");
    return true;
  });
}
