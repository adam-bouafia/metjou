import 'package:flutter/material.dart';
import 'package:metjou/utility/app_locale.dart';

class SafetyResource {
  const SafetyResource({
    required this.icon,
    required this.colors,
    required this.title,
    required this.description,
    required this.url,
    this.phone,
  });

  final IconData icon;
  final List<Color> colors;
  final String title;
  final String description;
  final String url;
  final String? phone;
}

/// Dutch support organisations. Numbers and links checked against the
/// organisations' own sites.
List<SafetyResource> safetyResources(BuildContext context) {
  final l10n = context.l10n;
  return [
    SafetyResource(
      icon: Icons.home_outlined,
      colors: const [Color(0xffC98BC1), Color(0xffB271AA)],
      title: l10n.resVeiligThuisTitle,
      description: l10n.resVeiligThuisDesc,
      phone: "0800-2000",
      url: "https://veiligthuis.nl/",
    ),
    SafetyResource(
      icon: Icons.health_and_safety_outlined,
      colors: const [Color(0xffF4A38C), Color(0xffE0705A)],
      title: l10n.resCsgTitle,
      description: l10n.resCsgDesc,
      phone: "0800-0188",
      url: "https://centrumseksueelgeweld.nl/",
    ),
    SafetyResource(
      icon: Icons.volunteer_activism_outlined,
      colors: const [Color(0xff7FB8E6), Color(0xff4A8FCC)],
      title: l10n.resSlachtofferhulpTitle,
      description: l10n.resSlachtofferhulpDesc,
      phone: "0900-0101",
      url: "https://www.slachtofferhulp.nl/",
    ),
    SafetyResource(
      icon: Icons.favorite_border,
      colors: const [Color(0xff5BC0A6), Color(0xff2E9E83)],
      title: l10n.res113Title,
      description: l10n.res113Desc,
      phone: "113",
      url: "https://www.113.nl/",
    ),
    SafetyResource(
      icon: Icons.local_police_outlined,
      colors: const [Color(0xff738AE6), Color(0xff5C5EDD)],
      title: l10n.resAangifteTitle,
      description: l10n.resAangifteDesc,
      phone: "0900-8844",
      url: "https://www.politie.nl/informatie/ik-wil-aangifte-doen.html",
    ),
    SafetyResource(
      icon: Icons.emergency_outlined,
      colors: const [Color(0xffFD8080), Color(0xffE53935)],
      title: l10n.res112Title,
      description: l10n.res112Desc,
      url: "https://www.rijksoverheid.nl/onderwerpen/alarmnummer-112",
    ),
  ];
}
