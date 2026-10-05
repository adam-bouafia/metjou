import 'package:metjou/features/tracker_watch/data/follow_detector.dart';
import 'package:metjou/features/tracker_watch/data/sighting_store.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:metjou/l10n/app_localizations.dart';

String trackerKindName(AppLocalizations l10n, TrackerKind kind) =>
    switch (kind) {
      TrackerKind.airTag => 'AirTag',
      TrackerKind.findMy => l10n.trackerKindFindMy,
      TrackerKind.airPods => 'AirPods',
      TrackerKind.smartTag => 'Samsung SmartTag',
      TrackerKind.googleFindMy => l10n.trackerKindGoogle,
      TrackerKind.tile => 'Tile',
      TrackerKind.chipolo => 'Chipolo',
      TrackerKind.pebblebee => 'Pebblebee',
    };

/// Time of day as 18:05, for texts made without a screen (notifications).
String clockTime(DateTime at) =>
    "${at.hour.toString().padLeft(2, '0')}:"
    "${at.minute.toString().padLeft(2, '0')}";

String followerSummary(AppLocalizations l10n, Follower follower) =>
    l10n.trackerFollowerSummary(
      follower.sightings.length,
      follower.places,
      clockTime(follower.firstSeen),
    );

/// Title and body of the warning for the followers in [due] (not empty).
({String title, String body}) trackerAlertText(
  AppLocalizations l10n,
  List<Follower> due,
) {
  final first = due.first;
  return (
    title: l10n.trackerAlertTitle,
    body: due.length > 1
        ? l10n.trackerAlertBodyMany(due.length)
        : l10n.trackerAlertBody(
            trackerKindName(l10n, first.kind),
            first.places,
            clockTime(first.firstSeen),
          ),
  );
}

String mapLink(Sighting sighting) =>
    "https://maps.google.com/?q=${sighting.lat},${sighting.lon}";

/// Diary text for a tracker: what it is, then one line per sighting with
/// the time and a map link, newest first.
String trackerDiaryText(
  AppLocalizations l10n, {
  required String device,
  required TrackerKind kind,
  required List<Sighting> sightings,
  required int places,
  required String Function(DateTime) formatDate,
}) {
  final summary = l10n.trackerDiaryText(
    trackerKindName(l10n, kind),
    deviceCode(device),
    sightings.length,
    places,
    formatDate(sightings.first.at),
    formatDate(sightings.last.at),
  );
  final lines = [
    for (final s in sightings.reversed)
      "${formatDate(s.at)}: ${s.hasPlace ? mapLink(s) : l10n.trackerNoPlace}",
  ];
  return [summary, "", ...lines].join("\n");
}
