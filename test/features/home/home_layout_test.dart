import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/features/emergency/presentation/emergency.dart';
import 'package:metjou/features/resources/presentation/widgets/safe_carousel.dart';
import 'package:metjou/l10n/app_localizations.dart';

Widget _app(Widget child, {double textScale = 1.0, String lang = 'nl'}) =>
    MaterialApp(
      theme: ThemeData(fontFamily: 'ReadexPro'),
      locale: Locale(lang),
      supportedLocales: supportedAppLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(360, 780),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(body: ListView(children: [child])),
      ),
    );

void main() {
  setUpAll(() async {
    // Real font: the default test font draws every glyph as a wide square.
    final font = FontLoader('ReadexPro')
      ..addFont(rootBundle.load('assets/fonts/ReadexPro-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/ReadexPro-Bold.ttf'));
    await font.load();
  });

  for (final scale in [1.0, 1.3]) {
    for (final lang in ['nl', 'ar']) {
      testWidgets('emergency cards fit at text scale $scale ($lang)', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(720, 1560);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          _app(const Emergency(), textScale: scale, lang: lang),
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(EmergencyCard), findsWidgets);
      });
    }
  }

  testWidgets('resource carousel shows full-width cards', (tester) async {
    tester.view.physicalSize = const Size(720, 1560);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const SafeCarousel()));
    expect(tester.takeException(), isNull);
    final card = tester.getSize(find.byType(Card).first);
    expect(card.width, greaterThan(250));
    expect(card.height, greaterThan(100));
  });
}
