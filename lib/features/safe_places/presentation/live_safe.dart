import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/widgets/glass.dart';
import 'package:url_launcher/url_launcher.dart';

/// Width of each place tile; its label is kept to the same width.
const _tileSize = 72.0;

/// Shortcuts that search Google Maps for safe places near the user.
class LiveSafe extends StatelessWidget {
  const LiveSafe({super.key});

  Future<void> _openMap(BuildContext context, String query) async {
    final failed = context.l10n.mapsOpenFailed;
    final url = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Fluttertoast.showToast(msg: failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spots = [
      ("assets/police.webp", l10n.policeStations, l10n.mapsQueryPolice),
      ("assets/hospital.webp", l10n.hospitals, l10n.mapsQueryHospital),
      ("assets/pharmacy.webp", l10n.pharmacies, l10n.mapsQueryPharmacy),
      ("assets/bus-stop.webp", l10n.busStations, l10n.mapsQueryTransport),
    ];
    return SizedBox(
      height: _tileSize + 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final (icon, label, query) in spots)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: SizedBox(
                width: _tileSize,
                child: Column(
                  children: [
                    GlassPanel(
                      radius: 16,
                      onTap: () => _openMap(context, query),
                      child: SizedBox.square(
                        dimension: _tileSize,
                        child: Center(child: Image.asset(icon, height: 36)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, height: 1.2),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
