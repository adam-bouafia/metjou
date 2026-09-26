import 'package:audio_background_record/audio_background_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metjou/Dashboard/Dashboard.dart';
import 'package:metjou/Onboarding/onboarding_screen.dart';
import 'package:metjou/Utility/app_locale.dart';
import 'package:metjou/Utility/background_services.dart';
import 'package:metjou/l10n/app_localizations.dart';
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
  await loadSavedLocale();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(onboardingDone: prefs.getBool("appOpenedBefore") ?? false));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.onboardingDone});

  final bool onboardingDone;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: appLocale,
      builder: (context, locale, _) => MaterialApp(
        locale: locale,
        supportedLocales: supportedAppLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        localeResolutionCallback: (system, _) => locale ?? resolveAppLocale(system),
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => 'MetJou',
        theme: ThemeData(
          fontFamily: 'ReadexPro',
          colorSchemeSeed: const Color(0xffB271AA),
        ),
        home: onboardingDone ? Dashboard() : OnboardingScreen(),
      ),
    );
  }
}
