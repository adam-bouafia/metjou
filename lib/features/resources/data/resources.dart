import 'package:flutter/material.dart';
import 'package:metjou/core/theme/app_theme.dart';
import 'package:metjou/core/localization/app_locale.dart';

class SafetyResource {
  const SafetyResource({
    required this.icon,
    required this.colors,
    required this.title,
    required this.description,
    required this.url,
    required this.image,
    this.phone,
  });

  final IconData icon;
  final List<Color> colors;
  final String title;
  final String description;
  final String url;

  /// Preview of the organisation's website, used as carousel background.
  final String image;
  final String? phone;
}

/// Dutch support organisations. Numbers and links checked against the
/// organisations' own sites.
List<SafetyResource> safetyResources(BuildContext context) {
  final l10n = context.l10n;
  return [
    SafetyResource(
      icon: Icons.home_outlined,
      colors: const [Latte.pink, Latte.mauve],
      title: l10n.resVeiligThuisTitle,
      description: l10n.resVeiligThuisDesc,
      phone: "0800-2000",
      url: "https://veiligthuis.nl/",
      image: "assets/resources/veilig_thuis.webp",
    ),
    SafetyResource(
      icon: Icons.health_and_safety_outlined,
      colors: const [Latte.peach, Latte.maroon],
      title: l10n.resCsgTitle,
      description: l10n.resCsgDesc,
      phone: "0800-0188",
      url: "https://centrumseksueelgeweld.nl/",
      image: "assets/resources/csg.webp",
    ),
    SafetyResource(
      icon: Icons.volunteer_activism_outlined,
      colors: const [Latte.lavender, Latte.blue],
      title: l10n.resSlachtofferhulpTitle,
      description: l10n.resSlachtofferhulpDesc,
      phone: "0900-0101",
      url: "https://www.slachtofferhulp.nl/",
      image: "assets/resources/slachtofferhulp.webp",
    ),
    SafetyResource(
      icon: Icons.favorite_border,
      colors: const [Latte.green, Latte.teal],
      title: l10n.res113Title,
      description: l10n.res113Desc,
      phone: "113",
      url: "https://www.113.nl/",
      image: "assets/resources/113.webp",
    ),
    SafetyResource(
      icon: Icons.diversity_3,
      colors: const [Latte.peach, Latte.pink],
      title: l10n.resSwitchboardTitle,
      description: l10n.resSwitchboardDesc,
      phone: "020-6236565",
      url: "https://switchboard.nl/",
      image: "assets/resources/switchboard.webp",
    ),
    SafetyResource(
      icon: Icons.local_police_outlined,
      colors: const [Latte.lavender, Latte.blue],
      title: l10n.resAangifteTitle,
      description: l10n.resAangifteDesc,
      phone: "0900-8844",
      url: "https://www.politie.nl/informatie/ik-wil-aangifte-doen.html",
      image: "assets/resources/politie.webp",
    ),
    SafetyResource(
      icon: Icons.emergency_outlined,
      colors: const [Latte.maroon, Latte.red],
      title: l10n.res112Title,
      description: l10n.res112Desc,
      url: "https://www.rijksoverheid.nl/onderwerpen/alarmnummer-112",
      image: "assets/resources/rijksoverheid.webp",
    ),
  ];
}
