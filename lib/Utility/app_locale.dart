import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:metjou/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = "locale";

/// Dutch first: it is the default when the phone language is not supported.
const supportedAppLocales = [
  Locale('nl'),
  Locale('en'),
  Locale('fr'),
  Locale('ar'),
  Locale('es'),
];

/// Language names shown in their own language in the picker.
const localeNames = {
  'nl': 'Nederlands',
  'en': 'English',
  'fr': 'Français',
  'ar': 'العربية',
  'es': 'Español',
};

/// The language picked in the app, or null to follow the phone.
final ValueNotifier<Locale?> appLocale = ValueNotifier(null);

Future<void> loadSavedLocale() async {
  final code = (await SharedPreferences.getInstance()).getString(_prefsKey);
  appLocale.value = code == null ? null : Locale(code);
}

Future<void> setAppLocale(Locale locale) async {
  await (await SharedPreferences.getInstance()).setString(_prefsKey, locale.languageCode);
  appLocale.value = locale;
}

/// Phone language if the app supports it, otherwise Dutch.
Locale resolveAppLocale(Locale? system) => supportedAppLocales.firstWhere(
      (l) => l.languageCode == system?.languageCode,
      orElse: () => supportedAppLocales.first,
    );

/// Strings for code that runs without a BuildContext, such as the shake
/// handler and background tasks.
Future<AppLocalizations> backgroundLocalizations() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final code = prefs.getString(_prefsKey);
  final locale = code != null
      ? Locale(code)
      : resolveAppLocale(PlatformDispatcher.instance.locale);
  return lookupAppLocalizations(locale);
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
