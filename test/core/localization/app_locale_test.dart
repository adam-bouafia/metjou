import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Dutch is the default when no language was picked', () async {
    await loadSavedLocale();
    expect(appLocale.value, isNull);
    expect((await backgroundLocalizations()).localeName, 'nl');
  });

  test('a picked language is saved and used in the background', () async {
    await setAppLocale(const Locale('ar'));
    await loadSavedLocale();
    expect(appLocale.value, const Locale('ar'));
    expect((await backgroundLocalizations()).localeName, 'ar');
  });

  test('every supported locale has generated strings', () {
    for (final locale in supportedAppLocales) {
      expect(lookupAppLocalizations(locale).smsSos, isNotEmpty);
    }
  });
}
