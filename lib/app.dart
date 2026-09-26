import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/theme/app_theme.dart';
import 'package:metjou/features/home/presentation/dashboard.dart';
import 'package:metjou/features/onboarding/presentation/onboarding_screen.dart';
import 'package:metjou/l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.onboardingDone});

  final bool onboardingDone;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: appLocale,
      builder: (context, locale, _) => MaterialApp(
        locale: locale ?? defaultAppLocale,
        supportedLocales: supportedAppLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => 'MetJou',
        theme: appTheme,
        home: onboardingDone ? Dashboard() : OnboardingScreen(),
      ),
    );
  }
}
