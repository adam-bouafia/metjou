import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/theme/app_theme.dart';
import 'package:metjou/core/widgets/glass.dart';
import 'package:metjou/features/tracker_watch/data/sighting_store.dart';
import 'package:metjou/features/tracker_watch/data/tracker_watch.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_actions.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_scan_screen.dart';

/// Whether a tracker is travelling with the user right now. The card's own
/// tiny "ViewModel": one derived value, no need for a Notifier.
final trackerFollowedProvider = FutureProvider<bool>((ref) async {
  final store = ref.read(sightingStoreOverrideProvider) ?? await SightingStore.open();
  final ignored = await TrackerWatch.ignored();
  final followers = await TrackerWatch.followers(store);
  return followers.any((f) => !ignored.contains(f.device));
});

/// Home card that opens the tracker screen. It also says so when a tracker
/// is travelling with the user, which matters most in discreet mode, where
/// there is no notification.
class TrackerScanCard extends ConsumerStatefulWidget {
  const TrackerScanCard({super.key});

  @override
  ConsumerState<TrackerScanCard> createState() => _TrackerScanCardState();
}

class _TrackerScanCardState extends ConsumerState<TrackerScanCard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The background task may have found something while the app was away.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(trackerFollowedProvider);
    }
  }

  Future<void> _open() async {
    await openTrackerScan(context);
    ref.invalidate(trackerFollowedProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    // The card still opens the screen when the history cannot be read.
    final followed = ref.watch(trackerFollowedProvider).value ?? false;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: GlassPanel(
        onTap: _open,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bluetooth_searching,
                    color: followed ? Latte.peach : scheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.trackerScan,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                followed ? l10n.trackerAlertTitle : l10n.trackerScanSubtitle,
                // Bold in the normal text colour: orange text is hard to
                // read on the light card.
                style: followed
                    ? const TextStyle(fontWeight: FontWeight.bold)
                    : TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
