import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/l10n/app_localizations.dart';

void main() {
  group('resolveAppLocale', () {
    for (final (system, expected) in [
      (const Locale('nl', 'NL'), 'nl'),
      (const Locale('en', 'GB'), 'en'),
      (const Locale('ar', 'MA'), 'ar'),
      (const Locale('es', 'ES'), 'es'),
      (const Locale('de', 'DE'), 'nl'),
      (null, 'nl'),
    ]) {
      test('maps $system to $expected', () {
        expect(resolveAppLocale(system).languageCode, expected);
      });
    }
  });

  test('every supported locale has generated strings', () {
    for (final locale in supportedAppLocales) {
      expect(lookupAppLocalizations(locale).smsSos, isNotEmpty);
    }
  });
}
