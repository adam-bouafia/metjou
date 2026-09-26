import 'package:flutter/material.dart';
import 'package:metjou/core/theme/app_theme.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/services/phone_call.dart';
import 'package:metjou/core/widgets/glass.dart';

class EmergencyNumber {
  const EmergencyNumber(
    this.number,
    this.icon,
    this.colors,
    this.title,
    this.description,
  );

  final String number;

  /// An asset path (String) or a Material icon (IconData).
  final Object icon;
  final List<Color> colors;
  final String title;
  final String description;
}

/// Dutch emergency and helpline numbers, checked against the official
/// sites (rijksoverheid.nl, 113.nl, politie.nl, veiligthuis.nl,
/// switchboard.nl). Suicide prevention comes right after 112 so it is
/// visible without scrolling.
List<EmergencyNumber> emergencyNumbers(BuildContext context) {
  final l10n = context.l10n;
  return [
    EmergencyNumber(
      "112",
      "assets/icons/alert.webp",
      const [Latte.maroon, Latte.red],
      l10n.emergency112Title,
      l10n.emergency112Desc,
    ),
    EmergencyNumber(
      "113",
      "assets/card.webp",
      const [Latte.green, Latte.teal],
      l10n.suicidePreventionTitle,
      l10n.suicidePreventionDesc,
    ),
    EmergencyNumber(
      "0900-8844",
      "assets/police.webp",
      const [Latte.lavender, Latte.blue],
      l10n.policeNonUrgentTitle,
      l10n.policeNonUrgentDesc,
    ),
    EmergencyNumber(
      "0800-2000",
      "assets/home.webp",
      const [Latte.pink, Latte.mauve],
      l10n.veiligThuisTitle,
      l10n.veiligThuisDesc,
    ),
    EmergencyNumber(
      "020-6236565",
      Icons.diversity_3,
      const [Latte.peach, Latte.pink],
      l10n.switchboardTitle,
      l10n.switchboardDesc,
    ),
  ];
}

class Emergency extends StatelessWidget {
  const Emergency({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.only(start: 6, end: 10),
        children: [
          for (final e in emergencyNumbers(context)) EmergencyCard(entry: e),
        ],
      ),
    );
  }
}

class EmergencyCard extends StatelessWidget {
  const EmergencyCard({super.key, required this.entry});

  final EmergencyNumber entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 6,
        end: 2,
        top: 4,
        bottom: 14,
      ),
      child: GlassPanel(
        colors: entry.colors,
        onTap: () => callNumber(entry.number),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.72,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.5),
                    radius: 22,
                    child: switch (entry.icon) {
                      final IconData icon => Icon(
                        icon,
                        color: Colors.white,
                        size: 26,
                      ),
                      final String asset => Image.asset(asset, height: 28),
                      _ => null,
                    },
                  ),
                  const Spacer(),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.call,
                              size: 16,
                              color: entry.colors.last,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              entry.number,
                              style: TextStyle(
                                color: entry.colors.last,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                entry.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  entry.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
