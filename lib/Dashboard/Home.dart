import 'dart:math';
import 'package:flutter/material.dart';
import 'package:metjou/Dashboard/Articles/AllArticles.dart';
import 'package:metjou/Dashboard/Articles/SafeCarousel.dart';
import 'package:metjou/Dashboard/DashWidgets/DashAppbar.dart';
import 'package:metjou/Dashboard/DashWidgets/Emergency.dart';
import 'package:metjou/Dashboard/DashWidgets/LiveSafe.dart';
import 'package:metjou/Dashboard/DashWidgets/SafeHome.dart';
import 'package:metjou/Utility/app_locale.dart';

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
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            ?trailing,
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashAppbar(onTap: nextQuote, quoteIndex: quoteIndex),
        Expanded(
          child: ListView(
            children: [
              _header(l10n.emergency),
              Emergency(),
              _header(
                l10n.resourcesTitle,
                trailing: TextButton(
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => AllArticles())),
                  child: Text(l10n.seeMore),
                ),
              ),
              SafeCarousel(),
              _header(l10n.safePlaces),
              LiveSafe(),
              SafeHome(),
              SizedBox(height: 50),
            ],
          ),
        ),
      ],
    );
  }
}
