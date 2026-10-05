import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/features/tracker_watch/data/sighting_store.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:metjou/features/tracker_watch/data/tracker_sound.dart';
import 'package:metjou/features/tracker_watch/data/tracker_watch.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_actions.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_detail_screen.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_finder_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support.dart';

const _device = '4C:00:00:00:A2:3F';

TrackerSubject _subject({
  TrackerKind kind = TrackerKind.airTag,
  List<Sighting>? history,
}) {
  final sightings = history ?? followingTrail(_device, kind: kind);
  return TrackerSubject(
    device: _device,
    last: sightings.isEmpty
        ? sightingAgo(_device, 0, kind: kind)
        : sightings.last,
    history: sightings,
  );
}

void main() {
  late FakeDiaryStore diary;
  late List<(TrackerKind, String)> rung;

  Widget screen(
    TrackerSubject subject, {
    SoundResult sound = SoundResult.playing,
    String lang = 'en',
    double textScale = 1.0,
  }) => testApp(
    TrackerDetailScreen(
      subject: subject,
      diary: diary,
      actions: TrackerActions(
        live: () => const Stream.empty(),
        playSound: (kind, address) async {
          rung.add((kind, address));
          return sound;
        },
      ),
    ),
    lang: lang,
    textScale: textScale,
  );

  Future<void> open(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    diary = FakeDiaryStore();
    rung = [];
  });

  testWidgets('shows what it is, how often it was seen and what to do', (
    tester,
  ) async {
    await open(tester, screen(_subject()));
    expect(find.text('AirTag'), findsOneWidget);
    expect(find.text('Code A2:3F'), findsOneWidget);
    expect(find.textContaining('Seen 3 times at 3 places since'), findsOne);
    expect(find.text('What you can do'), findsOneWidget);
    expect(find.textContaining('Call 112'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Veilig Thuis 0800-2000'), 200);
    expect(find.text('112'), findsOneWidget);
    expect(find.text('Politie 0900-8844'), findsOneWidget);
    expect(find.text('Slachtofferhulp 0900-0101'), findsOneWidget);
  });

  testWidgets('lists where it was seen, newest first, with a map link', (
    tester,
  ) async {
    final history = [
      sightingAgo(_device, 70, place: 0),
      sightingAgo(_device, 40),
      sightingAgo(_device, 5, place: 2),
    ];
    await open(tester, screen(_subject(history: history)));
    await tester.scrollUntilVisible(find.text('No location'), 200);
    expect(find.text('Where it was seen'), findsOneWidget);
    expect(find.text('Map'), findsNWidgets(2));
    expect(find.text('No location'), findsOneWidget);
    final rows = tester
        .widgetList<ListTile>(
          find.ancestor(
            of: find.byIcon(Icons.place_outlined),
            matching: find.byType(ListTile),
          ),
        )
        .toList();
    expect(rows, hasLength(3));
    // The newest row has a location, the middle one has not.
    expect(rows.first.trailing, isA<TextButton>());
    expect(rows[1].trailing, isA<Text>());
  });

  testWidgets('a tracker seen for the first time has no history yet', (
    tester,
  ) async {
    await open(tester, screen(_subject(history: [])));
    expect(find.textContaining('Seen just now'), findsOneWidget);
    expect(find.text('Ignore this tracker'), findsNothing);
    expect(find.text('Where it was seen'), findsNothing);
    expect(find.text('Save to diary'), findsOneWidget);
  });

  for (final (kind, canRing) in [
    (TrackerKind.airTag, true),
    (TrackerKind.googleFindMy, true),
    (TrackerKind.smartTag, false),
    (TrackerKind.tile, false),
  ]) {
    testWidgets('${kind.name} offers a sound: $canRing', (tester) async {
      await open(tester, screen(_subject(kind: kind)));
      expect(find.text('Play sound'), canRing ? findsOneWidget : findsNothing);
    });
  }

  for (final (result, message) in [
    (SoundResult.playing, 'The tracker should now make a sound.'),
    (SoundResult.unsupported, 'does not accept a sound request'),
    (SoundResult.unreachable, 'Move closer and try again'),
    (SoundResult.permissionDenied, 'needs the Nearby devices permission'),
  ]) {
    testWidgets('play sound reports ${result.name}', (tester) async {
      await open(tester, screen(_subject(), sound: result));
      await tester.tap(find.text('Play sound'));
      await tester.pump();
      expect(rung, [(TrackerKind.airTag, _device)]);
      expect(find.textContaining(message), findsOneWidget);
    });
  }

  testWidgets('save to diary writes what was seen and where', (tester) async {
    await open(tester, screen(_subject()));
    await tester.tap(find.text('Save to diary'));
    await tester.pump();
    expect(find.text('Saved in your diary.'), findsOneWidget);
    final text = diary.entries.single.text;
    expect(text, startsWith('Tracker found: AirTag, code A2:3F. Seen 3 times'));
    expect('https://maps.google.com'.allMatches(text), hasLength(3));
  });

  testWidgets('save to diary works for a tracker without history', (
    tester,
  ) async {
    await open(tester, screen(_subject(history: [])));
    await tester.tap(find.text('Save to diary'));
    await tester.pump();
    expect(
      diary.entries.single.text,
      startsWith('Tracker found: AirTag, code A2:3F, seen on'),
    );
  });

  testWidgets('ignore can be switched on and off again', (tester) async {
    await open(tester, screen(_subject()));
    await tester.tap(find.text('Ignore this tracker'));
    await tester.pumpAndSettle();
    expect(await TrackerWatch.ignored(), {_device});
    expect(find.text('Stop ignoring'), findsOneWidget);

    await tester.tap(find.text('Stop ignoring'));
    await tester.pumpAndSettle();
    expect(await TrackerWatch.ignored(), isEmpty);
    expect(find.text('Ignore this tracker'), findsOneWidget);
  });

  testWidgets('an ignored tracker opens with Stop ignoring', (tester) async {
    await TrackerWatch.setIgnored(_device, true);
    await open(tester, screen(_subject()));
    expect(find.text('Stop ignoring'), findsOneWidget);
  });

  testWidgets('Find it opens the finder', (tester) async {
    await open(tester, screen(_subject()));
    await tester.tap(find.text('Find it'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(TrackerFinderScreen), findsOneWidget);
    // Leave the finder so its timer stops.
    await tester.pumpWidget(const SizedBox());
  });

  for (final lang in ['nl', 'en', 'fr', 'es', 'ar']) {
    testWidgets('fits a small screen at large text ($lang)', (tester) async {
      tester.view.physicalSize = const Size(720, 1560);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      await open(tester, screen(_subject(), lang: lang, textScale: 1.3));
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Veilig Thuis 0800-2000'), findsOneWidget);
    });
  }
}
