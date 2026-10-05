import 'dart:convert';
import 'dart:io';

import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:path_provider/path_provider.dart';

/// One time a tracker was seen.
class Sighting {
  const Sighting({
    required this.device,
    required this.kind,
    required this.at,
    required this.address,
    required this.rssi,
    String? id,
    this.lat,
    this.lon,
    this.aging,
  }) : id = id ?? address;

  /// Key that stays the same for one physical tracker, also when it changes
  /// its address (see `resolveDevice`).
  final String device;
  final TrackerKind kind;
  final DateTime at;

  /// Bluetooth address at that moment, to find or ring the tracker.
  final String address;

  /// The tracker's own id at that moment (see `Tracker.id`).
  final String id;

  /// Signal strength in dBm.
  final int rssi;

  /// Where the phone was, when a location was available.
  final double? lat;
  final double? lon;

  /// SmartTag aging counter at that moment.
  final int? aging;

  bool get hasPlace => lat != null && lon != null;

  Map<String, Object?> toJson() => {
    'd': device,
    'k': kind.name,
    't': at.millisecondsSinceEpoch,
    'a': address,
    'r': rssi,
    'i': ?(id == address ? null : id),
    'lat': ?lat,
    'lon': ?lon,
    'g': ?aging,
  };

  /// Null for a damaged line or a tracker kind this version does not know.
  static Sighting? tryParse(String line) {
    try {
      final j = jsonDecode(line) as Map<String, dynamic>;
      return Sighting(
        device: j['d'] as String,
        kind: TrackerKind.values.byName(j['k'] as String),
        at: DateTime.fromMillisecondsSinceEpoch(j['t'] as int),
        address: j['a'] as String,
        rssi: j['r'] as int,
        id: j['i'] as String?,
        lat: (j['lat'] as num?)?.toDouble(),
        lon: (j['lon'] as num?)?.toDouble(),
        aging: j['g'] as int?,
      );
    } on Object {
      return null;
    }
  }
}

/// Sightings of trackers, one JSON object per line in the app's private
/// folder.
///
/// Why a log file: the app and the background task both add sightings, and
/// appending a line never overwrites what the other one wrote. Only
/// [prune] rewrites the file; a sighting added during that moment is lost,
/// which costs one data point out of many.
class SightingStore {
  /// A store in a given folder (used by tests).
  SightingStore.at(this.folder);

  final Directory folder;

  static Future<SightingStore> open() async {
    final base = await getApplicationDocumentsDirectory();
    return SightingStore.at(Directory("${base.path}/trackers"));
  }

  File get _file => File("${folder.path}/sightings.jsonl");

  static String _lines(Iterable<Sighting> sightings) =>
      sightings.map((s) => "${jsonEncode(s.toJson())}\n").join();

  /// Sightings from [since] on (all when null), oldest first.
  Future<List<Sighting>> load({DateTime? since}) async {
    if (!await _file.exists()) return [];
    return [
      for (final line in await _file.readAsLines())
        if (Sighting.tryParse(line) case final s?
            when since == null || !s.at.isBefore(since))
          s,
    ]..sort((a, b) => a.at.compareTo(b.at));
  }

  Future<void> append(Iterable<Sighting> sightings) async {
    if (sightings.isEmpty) return;
    await folder.create(recursive: true);
    await _file.writeAsString(
      _lines(sightings),
      mode: FileMode.append,
      flush: true,
    );
  }

  /// Removes sightings older than [before].
  Future<void> prune(DateTime before) async {
    if (!await _file.exists()) return;
    final keep = await load(since: before);
    final tmp = File("${_file.path}.tmp");
    await tmp.writeAsString(_lines(keep), flush: true);
    await tmp.rename(_file.path);
  }

  Future<void> clear() async {
    if (await _file.exists()) await _file.delete();
  }
}
