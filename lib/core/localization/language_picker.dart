import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';

/// Lists the supported languages by their own names and applies the choice.
Future<void> showLanguagePicker(BuildContext context) {
  final current = Localizations.localeOf(context).languageCode;
  return showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(context.l10n.chooseLanguage),
      children: [
        for (final locale in supportedAppLocales)
          SimpleDialogOption(
            onPressed: () {
              setAppLocale(locale);
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Expanded(child: Text(localeNames[locale.languageCode]!)),
                if (locale.languageCode == current)
                  const Icon(Icons.check, color: Color(0xffB271AA)),
              ],
            ),
          ),
      ],
    ),
  );
}
