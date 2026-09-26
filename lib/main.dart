import 'package:audio_background_record/audio_background_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metjou/app.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/services/background_services.dart';
import 'package:metjou/features/get_home_safe/data/get_home_safe_service.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:workmanager/workmanager.dart';

Future<void> _onShake() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final sendSmsOption = prefs.getBool("smsSend") ?? false;
  final audioRecordOption = prefs.getBool("bgRecord") ?? false;
  if (!sendSmsOption && !audioRecordOption) return;

  // Vibration feedback so the user knows the shake was registered.
  if (await Vibration.hasVibrator()) {
    Vibration.vibrate(duration: 2000);
  }

  if (sendSmsOption) {
    BackgroundServices.sendSms();
  }

  final recorder = AudioBackgroundRecord.getInstance();
  if (audioRecordOption &&
      (await recorder.isRecordingServiceRunning() ?? false)) {
    if (await recorder.isRecording() ?? false) {
      recorder.stopRecording();
    } else {
      recorder.startRecording();
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundServices.init();
  await BackgroundServices.checkService();

  ShakeDetector.autoStart(
    shakeThresholdGravity: 5,
    onPhoneShake: (_) => _onShake(),
  );
  await Workmanager().initialize(callbackDispatcher);
  await GetHomeSafeService.resume();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await loadSavedLocale();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(onboardingDone: prefs.getBool("appOpenedBefore") ?? false));
}
