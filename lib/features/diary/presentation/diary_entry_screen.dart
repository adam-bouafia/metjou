import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/features/diary/data/diary.dart';
import 'package:metjou/features/diary/presentation/diary_screen.dart';

/// Write or edit one diary entry.
class DiaryEntryScreen extends StatefulWidget {
  const DiaryEntryScreen({super.key, required this.store, this.entry});

  final DiaryStore store;
  final DiaryEntry? entry;

  @override
  State<DiaryEntryScreen> createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen> {
  late final DiaryEntry _entry =
      widget.entry ??
      DiaryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        when: DateTime.now(),
      );
  late final _text = TextEditingController(text: _entry.text);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _pickWhen() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _entry.when,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_entry.when),
    );
    if (time == null) return;
    setState(
      () => _entry.when = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _addPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(context.l10n.diaryCamera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.l10n.diaryGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2000,
      imageQuality: 85,
    );
    if (picked == null) return;
    final name = await widget.store.addPhoto(picked.path);
    setState(() => _entry.photos.add(name));
  }

  Future<void> _save() async {
    _entry.text = _text.text.trim();
    await widget.store.save(_entry);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.diaryDelete),
        content: Text(l10n.diaryDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.store.delete(_entry);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? l10n.diaryNew : l10n.diaryTitle),
        actions: [
          if (widget.entry != null)
            IconButton(
              tooltip: l10n.diaryDelete,
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
          TextButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(l10n.diaryWhen),
            subtitle: Text(formatDiaryDate(context, _entry.when)),
            onTap: _pickWhen,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _text,
            minLines: 6,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.diaryWhat,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.diaryPhotos, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final name in _entry.photos)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(widget.store.photo(name).path),
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    cacheWidth: 288,
                  ),
                ),
              SizedBox.square(
                dimension: 96,
                child: OutlinedButton(
                  onPressed: _addPhoto,
                  child: const Icon(Icons.add_a_photo_outlined),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
