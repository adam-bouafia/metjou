import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:url_launcher/url_launcher.dart';

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
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final (icon, label, query) in spots)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _openMap(context, query),
                      child: SizedBox(
                        height: 54,
                        width: 54,
                        child: Center(child: Image.asset(icon, height: 32)),
                      ),
                    ),
                  ),
                  Text(label, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
