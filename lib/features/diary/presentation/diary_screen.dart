import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/widgets/pin_guard.dart';
import 'package:metjou/features/diary/data/diary.dart';
import 'package:metjou/features/diary/data/diary_pdf.dart';
import 'package:metjou/features/diary/presentation/diary_entry_screen.dart';
import 'package:metjou/features/diary/presentation/diary_viewmodel.dart';
import 'package:share_plus/share_plus.dart';

/// Opens the diary after the PIN check (when a PIN is set).
Future<void> openDiary(BuildContext context) async {
  if (!await confirmPin(context) || !context.mounted) return;
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const DiaryScreen()),
  );
}

String formatDiaryDate(BuildContext context, DateTime when) {
  final m = MaterialLocalizations.of(context);
  return "${m.formatFullDate(when)}, ${m.formatTimeOfDay(TimeOfDay.fromDateTime(when), alwaysUse24HourFormat: true)}";
}

class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    DiaryEntry? entry,
  ) async {
    final store = await ref
        .read(diaryViewModelProvider.notifier)
        .resolveStore();
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiaryEntryScreen(store: store, entry: entry),
      ),
    );
    await ref.read(diaryViewModelProvider.notifier).refresh();
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    DiaryStore store,
    List<DiaryEntry> entries,
  ) async {
    final l10n = context.l10n;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final now = formatDiaryDate(context, DateTime.now());
    String format(DateTime d) => formatDiaryDate(context, d);
    final file = await exportDiaryPdf(
      store: store,
      entries: entries,
      title: l10n.diaryTitle,
      generatedLine: l10n.diaryPdfGenerated(now),
      formatDate: format,
      rtl: rtl,
    );
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], title: l10n.diaryTitle),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final diary = ref.watch(diaryViewModelProvider);
    final store = diary.store;
    final entries = diary.entries;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.diaryTitle),
        actions: [
          IconButton(
            tooltip: l10n.diaryExport,
            onPressed: entries.isEmpty || store == null
                ? null
                : () => _export(context, ref, store, entries),
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref, null),
        icon: const Icon(Icons.add),
        label: Text(l10n.diaryNew),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          if (!diary.hasPin)
            Card(
              color: scheme.primaryContainer,
              child: ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(l10n.diaryNoPin),
              ),
            ),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.diaryEmpty,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5),
              ),
            ),
          for (final e in entries)
            Card(
              child: ListTile(
                onTap: () => _edit(context, ref, e),
                leading: e.photos.isNotEmpty && store != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(store.photo(e.photos.first).path),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          cacheWidth: 144,
                        ),
                      )
                    : const Icon(Icons.edit_note, size: 32),
                title: Text(formatDiaryDate(context, e.when)),
                subtitle: Text(
                  e.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: e.photos.isEmpty
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo_outlined, size: 18),
                          Text(" ${e.photos.length}"),
                        ],
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
