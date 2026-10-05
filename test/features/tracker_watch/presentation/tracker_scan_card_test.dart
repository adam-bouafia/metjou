import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_scan_card.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_scan_screen.dart';
import 'package:metjou/l10n/app_localizations.dart';

Widget _app({String lang = 'en', double textScale = 1.0}) => MaterialApp(
  locale: Locale(lang),
  supportedLocales: supportedAppLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: Scaffold(body: ListView(children: const [TrackerScanCard()])),
);

void main() {
  testWidgets('opens the scan screen without starting a scan', (tester) async {
    await tester.pumpWidget(_app());
    expect(find.text('Tracker scan'), findsOneWidget);
    await tester.tap(find.text('Tracker scan'));
    await tester.pumpAndSettle();
    expect(find.byType(TrackerScanScreen), findsOneWidget);
    expect(find.text('Scan now'), findsOneWidget);
  });

  for (final lang in ['nl', 'en', 'fr', 'es', 'ar']) {
    testWidgets('fits a small screen at large text ($lang)', (tester) async {
      tester.view.physicalSize = const Size(720, 1560);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(lang: lang, textScale: 1.3));
      expect(tester.takeException(), isNull);
      expect(find.byType(TrackerScanCard), findsOneWidget);
    });
  }
}
