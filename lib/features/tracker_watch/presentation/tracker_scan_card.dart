import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/theme/app_theme.dart';
import 'package:metjou/core/widgets/glass.dart';
import 'package:metjou/features/tracker_watch/data/sighting_store.dart';
import 'package:metjou/features/tracker_watch/data/tracker_watch.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_scan_screen.dart';

/// Home card that opens the tracker screen. It also says so when a tracker
/// is travelling with the user, which matters most in discreet mode, where
/// there is no notification.
class TrackerScanCard extends StatefulWidget {
  const TrackerScanCard({super.key, this.store});

  /// Where sightings are kept; the app's own store when null.
  final SightingStore? store;

  @override
  State<TrackerScanCard> createState() => _TrackerScanCardState();
}

class _TrackerScanCardState extends State<TrackerScanCard>
    with WidgetsBindingObserver {
  bool _followed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The background task may have found something while the app was away.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    try {
      final store = widget.store ?? await SightingStore.open();
      final ignored = await TrackerWatch.ignored();
      final followers = await TrackerWatch.followers(store);
      final followed = followers.any((f) => !ignored.contains(f.device));
      if (mounted) setState(() => _followed = followed);
    } catch (e) {
      // The card still opens the screen when the history cannot be read.
      debugPrint("tracker card: $e");
    }
  }

  Future<void> _open() async {
    await openTrackerScan(context, store: widget.store);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
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
                    color: _followed ? Latte.peach : scheme.primary,
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
                _followed ? l10n.trackerAlertTitle : l10n.trackerScanSubtitle,
                // Bold in the normal text colour: orange text is hard to
                // read on the light card.
                style: _followed
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
