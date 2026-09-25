import 'package:audio_background_record/audio_background_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:metjou/Dashboard/Dashboard.dart';
import 'package:metjou/Onboarding/onboarding_screen.dart';
import 'package:metjou/Utility/background_services.dart';
import 'package:metjou/Utility/localeString.dart';
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
  if (audioRecordOption && (await recorder.isRecordingServiceRunning() ?? false)) {
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

  ShakeDetector.autoStart(shakeThresholdGravity: 5, onPhoneShake: (_) => _onShake());
  await Workmanager().initialize(callbackDispatcher);

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isAppOpeningForFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool result = prefs.getBool("appOpenedBefore") ?? false;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: LocaleString(),
      locale: Locale('fr', 'FR'),
      debugShowCheckedModeBanner: false,
      title: 'MetJou',
      theme: ThemeData(
        fontFamily: 'ReadexPro',
        colorSchemeSeed: const Color(0xffB271AA),
      ),
      home: FutureBuilder(
          future: isAppOpeningForFirstTime(),
          builder: (context, AsyncSnapshot<bool> snap) {
            if (snap.hasData) {
              if (snap.data!) {
                return Dashboard(); //Dashboard
              } else {
                return OnboardingScreen();
              }
            } else {
              return Container(
                color: Colors.transparent,
              );
            }
          }),
    );
  }
}
