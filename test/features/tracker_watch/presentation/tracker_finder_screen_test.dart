import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_actions.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_finder_screen.dart';

import '../support.dart';

const _device = '4C:00:00:00:A2:3F';

Tracker _advert(int rssi, {String address = _device}) => Tracker(
  kind: TrackerKind.airTag,
  owner: OwnerState.away,
  address: address,
  rssi: rssi,
);

void main() {
  late StreamController<Tracker> adverts;

  Future<void> open(WidgetTester tester, {String lang = 'en'}) async {
    await tester.pumpWidget(
      testApp(
        TrackerFinderScreen(
          subject: TrackerSubject(
            device: _device,
            last: sightingAgo(_device, 0),
          ),
          actions: TrackerActions(live: () => adverts.stream),
        ),
        lang: lang,
        textScale: lang == 'en' ? 1.0 : 1.3,
      ),
    );
    await tester.pump();
  }

  /// Sends readings one after the other, as a scan would.
  Future<void> hear(WidgetTester tester, List<Tracker> readings) async {
    for (final reading in readings) {
      adverts.add(reading);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 500));
  }

  double level(WidgetTester tester) => tester
      .widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator))
      .value!;

  setUp(() => adverts = StreamController<Tracker>());

  // Every test ends by leaving the screen, which stops its timer and its
  // subscription.
  Future<void> leave(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox());

  testWidgets('waits for a signal at first', (tester) async {
    await open(tester);
    expect(find.text('AirTag · Code A2:3F'), findsOneWidget);
    expect(find.text('Looking for its signal…'), findsOneWidget);
    expect(level(tester), 0);
    expect(find.textContaining('Walk around slowly'), findsOneWidget);
    await leave(tester);
  });

  testWidgets('shows how close the tracker is', (tester) async {
    await open(tester);
    await hear(tester, [_advert(-55)]);
    expect(find.text('Very close'), findsOneWidget);
    expect(level(tester), closeTo(0.75, 0.01));
    expect(find.text('Looking for its signal…'), findsNothing);
    await leave(tester);
  });

  testWidgets('ignores other trackers nearby', (tester) async {
    await open(tester);
    await hear(tester, [_advert(-40, address: '4C:99:99:99:99:99')]);
    expect(find.text('Looking for its signal…'), findsOneWidget);
    expect(level(tester), 0);
    await leave(tester);
  });

  testWidgets('says when the signal is getting stronger or weaker', (
    tester,
  ) async {
    await open(tester);
    await hear(tester, [
      for (final r in [-90, -86, -80, -74, -68, -62]) _advert(r),
    ]);
    expect(find.text('Getting closer'), findsOneWidget);
    await hear(tester, [
      for (final r in [-70, -78, -84, -90, -94, -96]) _advert(r),
    ]);
    expect(find.text('Getting further away'), findsOneWidget);
    await leave(tester);
  });

  testWidgets('notices when the signal is gone, and when it is back', (
    tester,
  ) async {
    await open(tester);
    await hear(tester, [_advert(-60)]);
    await tester.pump(const Duration(seconds: 8));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('No signal right now'), findsOneWidget);
    expect(level(tester), 0);

    await hear(tester, [_advert(-60)]);
    expect(find.textContaining('No signal right now'), findsNothing);
    expect(find.text('Very close'), findsOneWidget);
    await leave(tester);
  });

  testWidgets('says so when scanning is not possible', (tester) async {
    await open(tester);
    adverts.addError(StateError('bluetooth_off'));
    // One pump delivers the error, the next one draws the message.
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('did not work'), findsOneWidget);
    await leave(tester);
  });

  for (final lang in ['nl', 'fr', 'es', 'ar']) {
    testWidgets('fits a small screen at large text ($lang)', (tester) async {
      tester.view.physicalSize = const Size(720, 1560);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      await open(tester, lang: lang);
      await hear(tester, [_advert(-90), _advert(-60), _advert(-50)]);
      expect(tester.takeException(), isNull);
      await leave(tester);
    });
  }
}
