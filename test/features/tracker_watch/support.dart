import 'dart:io';

import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/features/diary/data/diary.dart';
import 'package:metjou/features/tracker_watch/data/sighting_store.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:metjou/l10n/app_localizations.dart';

/// Sightings in memory. Widget tests run on a fake clock, where real file
/// reads never finish.
class FakeSightingStore implements SightingStore {
  final List<Sighting> sightings = [];

  @override
  Directory get folder => Directory.systemTemp;

  @override
  Future<List<Sighting>> load({DateTime? since}) async => [
    for (final s in sightings)
      if (since == null || !s.at.isBefore(since)) s,
  ]..sort((a, b) => a.at.compareTo(b.at));

  @override
  Future<void> append(Iterable<Sighting> added) async =>
      sightings.addAll(added);

  @override
  Future<void> prune(DateTime before) async =>
      sightings.removeWhere((s) => s.at.isBefore(before));

  @override
  Future<void> clear() async => sightings.clear();
}

/// Diary entries in memory, for the same reason.
class FakeDiaryStore implements DiaryStore {
  final List<DiaryEntry> entries = [];

  @override
  Directory get folder => Directory.systemTemp;

  @override
  File photo(String name) => File("${folder.path}/$name");

  @override
  Future<List<DiaryEntry>> load() async => entries;

  @override
  Future<void> save(DiaryEntry entry) async => entries.add(entry);

  @override
  Future<void> delete(DiaryEntry entry) async => entries.remove(entry);

  @override
  Future<String> addPhoto(String sourcePath) async => sourcePath;
}

/// The app shell the tracker screens need: localisation and a text scale.
Widget testApp(Widget home, {String lang = 'en', double textScale = 1.0}) =>
    MaterialApp(
      locale: Locale(lang),
      supportedLocales: supportedAppLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: home,
    );

/// A sighting [minutesAgo] before now; every [place] step is about 222 m.
Sighting sightingAgo(
  String device,
  int minutesAgo, {
  int? place,
  TrackerKind kind = TrackerKind.airTag,
}) => Sighting(
  device: device,
  kind: kind,
  at: DateTime.now().subtract(Duration(minutes: minutesAgo)),
  address: device,
  rssi: -60,
  lat: place == null ? null : 52.37 + place * 0.002,
  lon: place == null ? null : 4.89,
);

/// Sightings that make [device] a follower right now: three places in a
/// good hour.
List<Sighting> followingTrail(
  String device, {
  TrackerKind kind = TrackerKind.airTag,
}) => [
  sightingAgo(device, 70, place: 0, kind: kind),
  sightingAgo(device, 40, place: 1, kind: kind),
  sightingAgo(device, 5, place: 2, kind: kind),
];
