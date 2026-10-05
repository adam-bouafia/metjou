import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/features/tracker_watch/data/tracker_scanner.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_scan_screen.dart';
import 'package:metjou/l10n/app_localizations.dart';

Widget _screen(
  Future<ScanOutcome> Function() scan, {
  String lang = 'en',
  double textScale = 1.0,
}) => MaterialApp(
  locale: Locale(lang),
  supportedLocales: supportedAppLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: TrackerScanScreen(scan: scan),
);

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

Future<void> _scan(WidgetTester tester) async {
  await tester.tap(find.text('Scan now'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('explains the scan and waits for a tap', (tester) async {
    var scans = 0;
    await tester.pumpWidget(
      _screen(() async {
        scans++;
        return const ScanOutcome.found([]);
      }),
    );
    expect(find.textContaining('could be tracking you'), findsOneWidget);
    expect(find.text('Scan now'), findsOneWidget);
    expect(scans, 0);
  });

  testWidgets('lists what was found with owner state, distance and code', (
    tester,
  ) async {
    await tester.pumpWidget(
      _screen(
        () async =>
            const ScanOutcome.found([_airTagAway, _tile, _smartTagNear]),
      ),
    );
    await _scan(tester);
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
    expect(find.text('Samsung SmartTag'), findsOneWidget);
    expect(find.text('With its owner · Further away'), findsOneWidget);
    expect(find.text('Scan again'), findsOneWidget);
  });

  testWidgets('no warning when every tracker is with its owner', (
    tester,
  ) async {
    await tester.pumpWidget(
      _screen(() async => const ScanOutcome.found([_smartTagNear])),
    );
    await _scan(tester);
    expect(find.text('Trackers nearby: 1'), findsOneWidget);
    expect(find.textContaining('Away from their owner'), findsNothing);
    expect(find.textContaining('Remember its code'), findsNothing);
  });

  testWidgets('says so when nothing is found', (tester) async {
    await tester.pumpWidget(_screen(() async => const ScanOutcome.found([])));
    await _scan(tester);
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
      await tester.pumpWidget(
        _screen(() async => ScanOutcome.blocked(blocker)),
      );
      await _scan(tester);
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
    await tester.pumpWidget(
      _screen(() {
        scans++;
        return done.future;
      }),
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

  for (final lang in ['nl', 'en', 'fr', 'es', 'ar']) {
    testWidgets('results fit a small screen at large text ($lang)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(720, 1560);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _screen(
          () async =>
              const ScanOutcome.found([_airTagAway, _tile, _smartTagNear]),
          lang: lang,
          textScale: 1.3,
        ),
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      // The list is longer than the screen; walk down to the last tracker.
      await tester.scrollUntilVisible(find.text('Samsung SmartTag'), 200);
      expect(tester.takeException(), isNull);
      expect(find.text('Samsung SmartTag'), findsOneWidget);
    });
  }

  test('trackerCode is the end of the address', () {
    expect(trackerCode(_airTagAway), 'A2:3F');
    expect(
      trackerCode(
        const Tracker(
          kind: TrackerKind.tile,
          owner: OwnerState.unknown,
          address: 'AB',
          rssi: -50,
        ),
      ),
      'AB',
    );
  });
}
