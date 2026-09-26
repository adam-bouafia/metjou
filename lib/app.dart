import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/navigation/app_navigator.dart';
import 'package:metjou/core/services/alert_countdown.dart';
import 'package:metjou/core/widgets/countdown_overlay.dart';
import 'package:metjou/core/theme/app_theme.dart';
import 'package:metjou/features/home/presentation/dashboard.dart';
import 'package:metjou/features/onboarding/presentation/onboarding_screen.dart';
import 'package:metjou/l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.onboardingDone});

  final bool onboardingDone;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appLocale, appThemeMode]),
      builder: (context, _) => MaterialApp(
        navigatorKey: appNavigatorKey,
        locale: appLocale.value ?? defaultAppLocale,
        supportedLocales: supportedAppLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => 'MetJou',
        theme: appTheme,
        darkTheme: appDarkTheme,
        themeMode: appThemeMode.value,
        builder: (context, child) => ValueListenableBuilder<int?>(
          valueListenable: AlertCountdown.remaining,
          builder: (context, seconds, _) => Stack(
            children: [
              child!,
              if (seconds != null) CountdownOverlay(seconds: seconds),
            ],
          ),
        ),
        home: onboardingDone ? Dashboard() : OnboardingScreen(),
      ),
    );
  }
}
