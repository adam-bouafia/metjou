import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// One incident: when it happened, what happened, and photos.
class DiaryEntry {
  DiaryEntry({
    required this.id,
    required this.when,
    this.text = "",
    List<String>? photos,
  }) : photos = photos ?? [];

  final String id;
  DateTime when;
  String text;

  /// File names inside the diary folder.
  final List<String> photos;

  Map<String, Object> toJson() => {
    "id": id,
    "when": when.toIso8601String(),
    "text": text,
    "photos": photos,
  };

  factory DiaryEntry.fromJson(Map<String, dynamic> j) => DiaryEntry(
    id: j["id"] as String,
    when: DateTime.parse(j["when"] as String),
    text: j["text"] as String? ?? "",
    photos: (j["photos"] as List? ?? []).cast<String>(),
  );
}

/// Diary entries and their photos, kept in the app's private folder so
/// deleting a photo from the gallery does not remove the evidence.
class DiaryStore {
  DiaryStore._(this.folder);

  /// A store in a given folder (used by tests).
  DiaryStore.at(this.folder);

  final Directory folder;

  static Future<DiaryStore> open() async {
    final base = await getApplicationDocumentsDirectory();
    final folder = Directory("${base.path}/diary");
    await folder.create(recursive: true);
    return DiaryStore._(folder);
  }

  File get _index => File("${folder.path}/entries.json");

  File photo(String name) => File("${folder.path}/$name");

  /// Newest first.
  Future<List<DiaryEntry>> load() async {
    if (!await _index.exists()) return [];
    final list = jsonDecode(await _index.readAsString()) as List;
    return list
        .map((e) => DiaryEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.when.compareTo(a.when));
  }

  Future<void> _write(List<DiaryEntry> entries) =>
      _index.writeAsString(jsonEncode(entries.map((e) => e.toJson()).toList()));

  Future<void> save(DiaryEntry entry) async {
    final entries = await load();
    entries.removeWhere((e) => e.id == entry.id);
    await _write([...entries, entry]);
  }

  Future<void> delete(DiaryEntry entry) async {
    for (final name in entry.photos) {
      final f = photo(name);
      if (await f.exists()) await f.delete();
    }
    final entries = await load()
      ..removeWhere((e) => e.id == entry.id);
    await _write(entries);
  }

  /// Copies a picked photo into the diary folder and returns its name.
  Future<String> addPhoto(String sourcePath) async {
    final ext = sourcePath.contains('.')
        ? sourcePath.substring(sourcePath.lastIndexOf('.'))
        : '.jpg';
    final name = "${DateTime.now().microsecondsSinceEpoch}$ext";
    await File(sourcePath).copy(photo(name).path);
    return name;
  }
}
