import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/features/tracker_watch/data/follow_detector.dart';
import 'package:metjou/features/tracker_watch/data/sighting_store.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:metjou/features/tracker_watch/data/tracker_text.dart';
import 'package:metjou/l10n/app_localizations.dart';

Sighting seen(
  int minutes, {
  int? place,
  String address = '4C:00:00:00:A2:3F',
}) => Sighting(
  device: '4C:00:00:00:A2:3F',
  kind: TrackerKind.airTag,
  at: DateTime(2026, 10, 5, 18, 5).add(Duration(minutes: minutes)),
  address: address,
  rssi: -60,
  lat: place == null ? null : 52.37 + place * 0.002,
  lon: place == null ? null : 4.89,
);

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final follower = Follower(
    device: '4C:00:00:00:A2:3F',
    sightings: [seen(0, place: 0), seen(30, place: 1), seen(65)],
    places: 2,
  );

  test('every kind has a name in every language', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      for (final kind in TrackerKind.values) {
        expect(trackerKindName(l10n, kind), isNotEmpty);
      }
    }
  });

  test('clockTime pads hours and minutes', () {
    expect(clockTime(DateTime(2026, 1, 1, 8, 5)), '08:05');
    expect(clockTime(DateTime(2026, 1, 1, 23, 59)), '23:59');
  });

  test('followerSummary says how often, where and since when', () {
    expect(
      followerSummary(en, follower),
      'Seen 3 times at 2 places since 18:05',
    );
  });

  test('the warning names a single tracker', () {
    final text = trackerAlertText(en, [follower]);
    expect(text.title, 'A tracker may be travelling with you');
    expect(
      text.body,
      'AirTag has been near you at 2 places since 18:05. '
      'Tap to see what you can do.',
    );
  });

  test('the warning counts several trackers', () {
    final text = trackerAlertText(en, [follower, follower]);
    expect(text.body, startsWith('2 trackers have been near you'));
  });

  test('the diary text lists every sighting, newest first', () {
    final text = trackerDiaryText(
      en,
      device: follower.device,
      kind: follower.kind,
      sightings: follower.sightings,
      places: follower.places,
      formatDate: clockTime,
    );
    expect(text.split('\n'), [
      'Tracker found: AirTag, code A2:3F. '
          'Seen 3 times at 2 places between 18:05 and 19:10.',
      '',
      '19:10: No location',
      '18:35: https://maps.google.com/?q=52.372,4.89',
      '18:05: https://maps.google.com/?q=52.37,4.89',
    ]);
  });
}
