import 'dart:async';
import 'package:flutter/material.dart';
import 'package:metjou/core/theme/app_theme.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:lottie/lottie.dart';
import 'package:metjou/features/home/presentation/dashboard.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 1500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf5ebe2),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Lottie.asset(
              'assets/blossoms.json',
              height: MediaQuery.of(context).size.width * 1.2,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 80),
              child: Image.asset("assets/logosplash.webp", height: 180),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 180.0),
              child: Text(
                "MetJou",
                style: TextStyle(
                  color: Color(0xff6A3085),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 140.0),
              child: Text(
                context.l10n.tagline,
                style: TextStyle(color: AppColors.primary, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
