import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/features/diary/data/diary.dart';

void main() {
  late Directory dir;
  late DiaryStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('diary_test');
    store = DiaryStore.at(dir);
  });

  tearDown(() => dir.delete(recursive: true));

  test('entries load back newest first', () async {
    await store.save(
      DiaryEntry(id: 'a', when: DateTime(2026, 1, 1), text: 'first'),
    );
    await store.save(
      DiaryEntry(id: 'b', when: DateTime(2026, 3, 1), text: 'second'),
    );
    final entries = await store.load();
    expect(entries.map((e) => e.text), ['second', 'first']);
  });

  test('saving an existing entry updates it', () async {
    final entry = DiaryEntry(
      id: 'a',
      when: DateTime(2026, 1, 1),
      text: 'draft',
    );
    await store.save(entry);
    entry.text = 'final';
    await store.save(entry);
    final entries = await store.load();
    expect(entries.single.text, 'final');
  });

  test('photos are copied in and deleted with the entry', () async {
    final source = File('${dir.path}/source.jpg')..writeAsBytesSync([1, 2, 3]);
    final name = await store.addPhoto(source.path);
    source.deleteSync();
    expect(
      store.photo(name).existsSync(),
      isTrue,
      reason: 'copy survives the original',
    );

    final entry = DiaryEntry(
      id: 'a',
      when: DateTime(2026, 1, 1),
      photos: [name],
    );
    await store.save(entry);
    await store.delete(entry);
    expect(store.photo(name).existsSync(), isFalse);
    expect(await store.load(), isEmpty);
  });
}
