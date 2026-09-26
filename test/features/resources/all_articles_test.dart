import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/features/resources/presentation/all_articles.dart';
import 'package:metjou/l10n/app_localizations.dart';

void main() {
  testWidgets('See more lists every resource', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('nl'),
        supportedLocales: supportedAppLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const AllArticles(),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Veilig Thuis'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });
}
