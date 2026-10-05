import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/widgets/glass.dart';
import 'package:metjou/features/tracker_watch/presentation/tracker_scan_screen.dart';

/// Home card that opens the tracker scan.
class TrackerScanCard extends StatelessWidget {
  const TrackerScanCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: GlassPanel(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TrackerScanScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bluetooth_searching, color: scheme.primary),
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
                l10n.trackerScanSubtitle,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
