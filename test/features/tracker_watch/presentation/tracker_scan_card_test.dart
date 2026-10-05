import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/features/tracker_watch/data/tracker_watch.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_scan_card.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_scan_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support.dart';

void main() {
  late FakeSightingStore store;

  Widget card({String lang = 'en', double textScale = 1.0}) => testApp(
    Scaffold(
      body: ListView(children: [TrackerScanCard(store: store)]),
    ),
    lang: lang,
    textScale: textScale,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = FakeSightingStore();
  });

  testWidgets('opens the tracker screen without starting a scan', (
    tester,
  ) async {
    await tester.pumpWidget(card());
    await tester.pumpAndSettle();
    expect(find.text('Check for AirTags and other tags near you'), findsOne);
    await tester.tap(find.text('Tracker scan'));
    await tester.pumpAndSettle();
    expect(find.byType(TrackerScanScreen), findsOneWidget);
    expect(find.text('Scan now'), findsOneWidget);
  });

  testWidgets('asks for the PIN first when one is set', (tester) async {
    SharedPreferences.setMockInitialValues({'pin': 1234});
    await tester.pumpWidget(card());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tracker scan'));
    // The PIN field's cursor blinks for ever, so this cannot wait to settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(TrackerScanScreen), findsNothing);
    expect(find.text('Enter your PIN'), findsOneWidget);
  });

  testWidgets('says so when a tracker is travelling along', (tester) async {
    store.sightings.addAll(followingTrail('4C:00:00:00:A2:3F'));
    await tester.pumpWidget(card());
    await tester.pumpAndSettle();
    expect(find.text('A tracker may be travelling with you'), findsOneWidget);
    expect(
      find.text('Check for AirTags and other tags near you'),
      findsNothing,
    );
  });

  testWidgets('stays calm about an ignored tracker', (tester) async {
    store.sightings.addAll(followingTrail('4C:00:00:00:A2:3F'));
    await TrackerWatch.setIgnored('4C:00:00:00:A2:3F', true);
    await tester.pumpWidget(card());
    await tester.pumpAndSettle();
    expect(find.text('A tracker may be travelling with you'), findsNothing);
  });

  for (final lang in ['nl', 'en', 'fr', 'es', 'ar']) {
    testWidgets('fits a small screen at large text ($lang)', (tester) async {
      tester.view.physicalSize = const Size(720, 1560);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      store.sightings.addAll(followingTrail('4C:00:00:00:A2:3F'));
      await tester.pumpWidget(card(lang: lang, textScale: 1.3));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(TrackerScanCard), findsOneWidget);
    });
  }
}
