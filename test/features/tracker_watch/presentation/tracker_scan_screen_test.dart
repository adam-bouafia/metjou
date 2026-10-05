import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/features/tracker_watch/data/tracker_scanner.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:metjou/features/tracker_watch/data/tracker_watch.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_actions.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_detail_screen.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_scan_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support.dart';

const _airTagAway = Tracker(
  kind: TrackerKind.airTag,
  owner: OwnerState.away,
  address: '4C:11:22:33:A2:3F',
  rssi: -52,
);
const _tile = Tracker(
  kind: TrackerKind.tile,
  owner: OwnerState.unknown,
  address: 'E0:11:22:33:44:55',
  rssi: -70,
);
const _smartTagNear = Tracker(
  kind: TrackerKind.smartTag,
  owner: OwnerState.near,
  address: '7A:11:22:33:0B:C4',
  rssi: -88,
);

Future<ScanOutcome> _nothing() async => const ScanOutcome.found([]);

void main() {
  late FakeSightingStore store;
  // What the screen asked the platform to do.
  late List<bool> watchSwitched;
  late int watchChecks;

  Widget screen({
    Future<ScanOutcome> Function() scan = _nothing,
    ScanBlocker? watchBlocker,
    String lang = 'en',
    double textScale = 1.0,
  }) => testApp(
    TrackerScanScreen(
      store: store,
      actions: TrackerActions(
        scan: scan,
        checkWatch: () async {
          watchChecks++;
          return watchBlocker;
        },
        setWatch: (on) async => watchSwitched.add(on),
        place: () async => (lat: 52.37, lon: 4.89),
      ),
    ),
    lang: lang,
    textScale: textScale,
  );

  Future<void> open(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  Future<void> tapScan(WidgetTester tester) async {
    await tester.tap(find.text('Scan now'));
    await tester.pumpAndSettle();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = FakeSightingStore();
    watchSwitched = [];
    watchChecks = 0;
  });

  group('scan now', () {
    testWidgets('explains the scan and waits for a tap', (tester) async {
      var scans = 0;
      await open(
        tester,
        screen(
          scan: () async {
            scans++;
            return const ScanOutcome.found([]);
          },
        ),
      );
      expect(find.textContaining('could be tracking you'), findsOneWidget);
      expect(find.text('Scan now'), findsOneWidget);
      expect(find.text('Travelling with you'), findsNothing);
      expect(scans, 0);
    });

    testWidgets('lists what was found with owner state, distance and code', (
      tester,
    ) async {
      await open(
        tester,
        screen(
          scan: () async =>
              const ScanOutcome.found([_airTagAway, _tile, _smartTagNear]),
        ),
      );
      await tapScan(tester);
      expect(find.text('Trackers nearby: 3'), findsOneWidget);
      expect(find.text('Away from their owner: 1'), findsOneWidget);
      expect(find.text('AirTag'), findsOneWidget);
      expect(find.text('Away from its owner · Very close'), findsOneWidget);
      expect(find.text('Code A2:3F'), findsOneWidget);
      expect(find.text('Tile'), findsOneWidget);
      expect(
        find.text('Cannot tell if its owner is near · Close'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(find.text('Samsung SmartTag'), 200);
      expect(find.text('With its owner · Further away'), findsOneWidget);
      expect(find.text('Scan again'), findsOneWidget);
    });

    testWidgets('no warning when every tracker is with its owner', (
      tester,
    ) async {
      await open(
        tester,
        screen(scan: () async => const ScanOutcome.found([_smartTagNear])),
      );
      await tapScan(tester);
      expect(find.text('Trackers nearby: 1'), findsOneWidget);
      expect(find.textContaining('Away from their owner'), findsNothing);
      expect(find.textContaining('Remember its code'), findsNothing);
    });

    testWidgets('says so when nothing is found', (tester) async {
      await open(tester, screen());
      await tapScan(tester);
      expect(find.text('No trackers found near you.'), findsOneWidget);
    });

    for (final (blocker, text, hasSettings) in [
      (ScanBlocker.unsupported, 'no Bluetooth Low Energy', false),
      (ScanBlocker.bluetoothOff, 'Turn on Bluetooth', false),
      (ScanBlocker.permissionDenied, 'Nearby devices', true),
      (ScanBlocker.locationOff, 'Turn on location', true),
      (ScanBlocker.failed, 'did not work', false),
    ]) {
      testWidgets('explains a scan blocked by ${blocker.name}', (tester) async {
        await open(
          tester,
          screen(scan: () async => ScanOutcome.blocked(blocker)),
        );
        await tapScan(tester);
        expect(find.textContaining(text), findsOneWidget);
        expect(
          find.text('Open settings'),
          hasSettings ? findsOneWidget : findsNothing,
        );
        expect(find.textContaining('Trackers nearby'), findsNothing);
      });
    }

    testWidgets('cannot start a second scan while one runs', (tester) async {
      final done = Completer<ScanOutcome>();
      var scans = 0;
      await open(
        tester,
        screen(
          scan: () {
            scans++;
            return done.future;
          },
        ),
      );
      await tester.tap(find.text('Scan now'));
      await tester.pump();
      expect(find.text('Scanning…'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Scanning…'));
      await tester.pump();
      expect(scans, 1);

      done.complete(const ScanOutcome.found([]));
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('Scan again'), findsOneWidget);
    });

    testWidgets('a tap on a found tracker opens its details', (tester) async {
      await open(
        tester,
        screen(scan: () async => const ScanOutcome.found([_airTagAway])),
      );
      await tapScan(tester);
      await tester.tap(find.text('AirTag'));
      await tester.pumpAndSettle();
      expect(find.byType(TrackerDetailScreen), findsOneWidget);
      expect(find.textContaining('Seen just now'), findsOneWidget);
    });

    for (final lang in ['nl', 'en', 'fr', 'es', 'ar']) {
      testWidgets('results fit a small screen at large text ($lang)', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(720, 1560);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);
        store.sightings.addAll(followingTrail('4C:00:00:00:00:77'));
        await open(
          tester,
          screen(
            scan: () async =>
                const ScanOutcome.found([_airTagAway, _tile, _smartTagNear]),
            lang: lang,
            textScale: 1.3,
          ),
        );
        await tester.scrollUntilVisible(find.byType(FilledButton), 200);
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        // The list is longer than the screen; walk down to the last tracker.
        await tester.scrollUntilVisible(find.text('Samsung SmartTag'), 200);
        expect(tester.takeException(), isNull);
        expect(find.text('Samsung SmartTag'), findsOneWidget);
      });
    }
  });

  group('background watch', () {
    testWidgets('is off at first, and switching it on asks for what it needs', (
      tester,
    ) async {
      await open(tester, screen());
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(watchChecks, 1);
      expect(watchSwitched, [true]);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });

    testWidgets('stays off and says why when something blocks it', (
      tester,
    ) async {
      await open(tester, screen(watchBlocker: ScanBlocker.backgroundLocation));
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(watchSwitched, isEmpty);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      expect(find.textContaining('Allow all the time'), findsOneWidget);
      expect(find.text('Open settings'), findsOneWidget);
    });

    testWidgets('switching it off needs no checks', (tester) async {
      SharedPreferences.setMockInitialValues({'trackerWatch': true});
      await open(tester, screen());
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(watchChecks, 0);
      expect(watchSwitched, [false]);
    });

    testWidgets('shows the last check, and the note for discreet mode', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'trackerWatch': true,
        'discreet': true,
        'trackerLastCheck': DateTime(
          2026,
          10,
          5,
          18,
          42,
        ).millisecondsSinceEpoch,
      });
      await open(tester, screen());
      expect(find.textContaining('Last check: 18:42'), findsOneWidget);
      expect(find.textContaining('Discreet mode is on'), findsOneWidget);
    });

    testWidgets('a manual scan adds to the history while the watch is on', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'trackerWatch': true});
      await open(
        tester,
        screen(
          scan: () async =>
              const ScanOutcome.found([_airTagAway, _smartTagNear]),
        ),
      );
      await tapScan(tester);
      final stored = store.sightings.single;
      expect(stored.device, _airTagAway.address);
      expect((stored.lat, stored.lon), (52.37, 4.89));
    });

    testWidgets('a manual scan stores nothing while the watch is off', (
      tester,
    ) async {
      await open(
        tester,
        screen(scan: () async => const ScanOutcome.found([_airTagAway])),
      );
      await tapScan(tester);
      expect(store.sightings, isEmpty);
    });
  });

  group('followers', () {
    testWidgets('a tracker that travelled along is shown first', (
      tester,
    ) async {
      store.sightings.addAll(followingTrail('4C:00:00:00:A2:3F'));
      await open(tester, screen());
      expect(find.text('Travelling with you'), findsOneWidget);
      expect(find.text('AirTag'), findsOneWidget);
      expect(find.textContaining('Seen 3 times at 3 places'), findsOneWidget);
      expect(find.text('Code A2:3F'), findsOneWidget);

      await tester.tap(find.text('AirTag'));
      await tester.pumpAndSettle();
      expect(find.byType(TrackerDetailScreen), findsOneWidget);
    });

    testWidgets('an ignored follower is listed apart', (tester) async {
      store.sightings.addAll(followingTrail('4C:00:00:00:A2:3F'));
      await TrackerWatch.setIgnored('4C:00:00:00:A2:3F', true);
      await open(tester, screen());
      expect(find.text('Travelling with you'), findsNothing);
      await tester.scrollUntilVisible(find.text('Ignored'), 200);
      expect(find.text('AirTag'), findsOneWidget);
    });

    testWidgets('the history can be deleted after a confirmation', (
      tester,
    ) async {
      store.sightings.addAll(followingTrail('4C:00:00:00:A2:3F'));
      await open(tester, screen());
      await tester.tap(find.byTooltip('Delete history'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Delete all tracker sightings'),
        findsOneWidget,
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(store.sightings, hasLength(3));

      await tester.tap(find.byTooltip('Delete history'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(store.sightings, isEmpty);
      expect(find.text('Travelling with you'), findsNothing);
      expect(find.byTooltip('Delete history'), findsNothing);
    });

    testWidgets('no delete button without a history', (tester) async {
      await open(tester, screen());
      expect(find.byTooltip('Delete history'), findsNothing);
    });
  });
}
