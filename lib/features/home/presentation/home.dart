import 'dart:math';
import 'package:flutter/material.dart';
import 'package:metjou/features/resources/presentation/all_articles.dart';
import 'package:metjou/features/resources/presentation/widgets/safe_carousel.dart';
import 'package:metjou/features/home/presentation/widgets/dash_appbar.dart';
import 'package:metjou/features/home/presentation/widgets/glass_dock.dart';
import 'package:metjou/features/home/presentation/widgets/quick_tools.dart';
import 'package:metjou/features/emergency/presentation/emergency.dart';
import 'package:metjou/features/safe_places/presentation/live_safe.dart';
import 'package:metjou/features/check_in/presentation/check_in_card.dart';
import 'package:metjou/features/get_home_safe/presentation/safe_home.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/widgets/entrance.dart';
import 'package:metjou/core/widgets/glass.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int quoteIndex = Random().nextInt(3);

  void nextQuote() => setState(() => quoteIndex = (quoteIndex + 1) % 3);

  Widget _header(String title, {Widget? trailing}) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        ?trailing,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GlassBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashAppbar(onTap: nextQuote, quoteIndex: quoteIndex),
          Expanded(
            child: ListView(
              children: [
                for (final (i, section) in [
                  _header(
                    l10n.resourcesTitle,
                    trailing: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AllArticles()),
                      ),
                      child: Text(l10n.seeMore),
                    ),
                  ),
                  SafeCarousel(),
                  _header(l10n.emergency),
                  Emergency(),
                  _header(l10n.quickTools),
                  QuickTools(),
                  _header(l10n.safePlaces),
                  LiveSafe(),
                  SafeHome(),
                  CheckInCard(),
                ].indexed)
                  Entrance(index: i, child: section),
                SizedBox(height: glassDockClearance),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
