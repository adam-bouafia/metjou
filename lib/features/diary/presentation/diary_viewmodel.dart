import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metjou/core/widgets/pin_guard.dart';
import 'package:metjou/features/diary/data/diary.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_actions.dart'
    show diaryStoreOverrideProvider;
import 'package:shared_preferences/shared_preferences.dart';

class DiaryState {
  const DiaryState({this.store, this.entries = const [], this.hasPin = true});

  final DiaryStore? store;
  final List<DiaryEntry> entries;
  final bool hasPin;
}

/// Loads the diary once instead of on every rebuild. Shares the
/// [diaryStoreOverrideProvider] DI seam with the tracker detail screen,
/// which also writes a diary entry.
class DiaryViewModel extends Notifier<DiaryState> {
  DiaryStore? _store;

  @override
  DiaryState build() {
    _reload();
    return const DiaryState();
  }

  Future<DiaryStore> resolveStore() async => _store ??=
      ref.read(diaryStoreOverrideProvider) ?? await DiaryStore.open();

  Future<void> _reload() async {
    final store = await resolveStore();
    final entries = await store.load();
    final pin = (await SharedPreferences.getInstance()).getInt('pin') ?? noPin;
    state = DiaryState(store: store, entries: entries, hasPin: pin != noPin);
  }

  Future<void> refresh() => _reload();
}

final diaryViewModelProvider = NotifierProvider<DiaryViewModel, DiaryState>(
  DiaryViewModel.new,
);
