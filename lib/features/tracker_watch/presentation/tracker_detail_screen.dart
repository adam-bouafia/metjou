import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/services/phone_call.dart';
import 'package:metjou/features/diary/data/diary.dart';
import 'package:metjou/features/tracker_watch/data/follow_detector.dart';
import 'package:metjou/features/tracker_watch/data/sighting_store.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';
import 'package:metjou/features/tracker_watch/data/tracker_sound.dart';
import 'package:metjou/features/tracker_watch/data/tracker_text.dart';
import 'package:metjou/features/tracker_watch/data/tracker_watch.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_actions.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_finder_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dutch help lines for someone who found a tracker.
const _helpLines = [
  ("112", "112"),
  ("Politie", "0900-8844"),
  ("Slachtofferhulp", "0900-0101"),
  ("Veilig Thuis", "0800-2000"),
];

/// Most sightings listed; older ones stay in the diary text.
const _maxHistoryRows = 30;

/// Everything about one tracker: where it was seen, how to find it and
/// what to do about it.
class TrackerDetailScreen extends StatefulWidget {
  const TrackerDetailScreen({
    super.key,
    required this.subject,
    this.actions = const TrackerActions(),
    this.diary,
  });

  final TrackerSubject subject;
  final TrackerActions actions;

  /// Where "Save to diary" writes; the app's diary when null.
  final DiaryStore? diary;

  @override
  State<TrackerDetailScreen> createState() => _TrackerDetailScreenState();
}

class _TrackerDetailScreenState extends State<TrackerDetailScreen> {
  bool _ignored = false;
  bool _ringing = false;

  TrackerSubject get _subject => widget.subject;
  List<Sighting> get _history => _subject.history;

  @override
  void initState() {
    super.initState();
    TrackerWatch.ignored().then((ignored) {
      if (mounted) setState(() => _ignored = ignored.contains(_subject.device));
    });
  }

  String _when(DateTime at) {
    final m = MaterialLocalizations.of(context);
    return "${m.formatMediumDate(at)} ${m.formatTimeOfDay(TimeOfDay.fromDateTime(at), alwaysUse24HourFormat: true)}";
  }

  void _say(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _playSound() async {
    final l10n = context.l10n;
    setState(() => _ringing = true);
    final result = await widget.actions.playSound(
      _subject.kind,
      _subject.last.address,
    );
    if (!mounted) return;
    setState(() => _ringing = false);
    _say(switch (result) {
      SoundResult.playing => l10n.trackerSoundPlaying,
      SoundResult.unsupported => l10n.trackerSoundUnsupported,
      SoundResult.unreachable => l10n.trackerSoundFailed,
      SoundResult.permissionDenied => l10n.trackerSoundPermission,
    });
  }

  Future<void> _saveToDiary() async {
    final l10n = context.l10n;
    final kind = trackerKindName(l10n, _subject.kind);
    final text = _history.isEmpty
        ? l10n.trackerDiaryTextOnce(
            kind,
            deviceCode(_subject.device),
            _when(_subject.last.at),
          )
        : trackerDiaryText(
            l10n,
            device: _subject.device,
            kind: _subject.kind,
            sightings: _history,
            places: distinctPlaces(
              _history,
              const FollowRule().placeRadius,
            ).length,
            formatDate: _when,
          );
    final diary = widget.diary ?? await DiaryStore.open();
    final now = DateTime.now();
    await diary.save(
      DiaryEntry(
        id: now.microsecondsSinceEpoch.toString(),
        when: now,
        text: text,
      ),
    );
    if (mounted) _say(l10n.trackerSavedDiary);
  }

  Future<void> _toggleIgnored() async {
    await TrackerWatch.setIgnored(_subject.device, !_ignored);
    if (mounted) setState(() => _ignored = !_ignored);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final places = distinctPlaces(_history, const FollowRule().placeRadius);
    final rows = _history.reversed.take(_maxHistoryRows);
    return Scaffold(
      appBar: AppBar(title: Text(trackerKindName(l10n, _subject.kind))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: ListTile(
              leading: Icon(
                _subject.kind == TrackerKind.airPods
                    ? Icons.headphones
                    : Icons.sell_outlined,
              ),
              title: Text(l10n.trackerCode(deviceCode(_subject.device))),
              subtitle: Text(
                _history.isEmpty
                    ? l10n.trackerSeenNow
                    : l10n.trackerFollowerSummary(
                        _history.length,
                        places.length,
                        _when(_history.first.at),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrackerFinderScreen(
                      subject: _subject,
                      actions: widget.actions,
                    ),
                  ),
                ),
                icon: const Icon(Icons.radar),
                label: Text(l10n.trackerFind),
              ),
              if (canPlaySound(_subject.kind))
                FilledButton.tonalIcon(
                  onPressed: _ringing ? null : _playSound,
                  icon: const Icon(Icons.volume_up),
                  label: Text(l10n.trackerPlaySound),
                ),
              OutlinedButton.icon(
                onPressed: _saveToDiary,
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(l10n.trackerSaveDiary),
              ),
              if (_history.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: _toggleIgnored,
                  icon: Icon(
                    _ignored
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                  ),
                  label: Text(
                    _ignored ? l10n.trackerUnignore : l10n.trackerIgnore,
                  ),
                ),
            ],
          ),
          if (_history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l10n.trackerIgnoreHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          _Heading(l10n.trackerHelpTitle),
          for (final (i, step) in [
            l10n.trackerHelpDanger,
            l10n.trackerHelpFind,
            l10n.trackerHelpRecord,
            l10n.trackerHelpDisable,
            l10n.trackerHelpPolice,
            l10n.trackerHelpTalk,
          ].indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      "${i + 1}.",
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(step, style: const TextStyle(height: 1.4)),
                  ),
                ],
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final (name, number) in _helpLines)
                ActionChip(
                  avatar: const Icon(Icons.call, size: 18),
                  label: Text(name == number ? number : "$name $number"),
                  onPressed: () => callNumber(number),
                ),
            ],
          ),
          if (_history.isNotEmpty) ...[
            _Heading(l10n.trackerHistoryTitle),
            for (final sighting in rows)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.place_outlined),
                title: Text(_when(sighting.at)),
                trailing: sighting.hasPlace
                    ? TextButton(
                        onPressed: () => launchUrl(
                          Uri.parse(mapLink(sighting)),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: Text(l10n.trackerOpenMap),
                      )
                    : Text(
                        l10n.trackerNoPlace,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 10),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}
