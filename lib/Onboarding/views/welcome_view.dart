import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metjou/Onboarding/views/onboarding_page.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key, required this.animationController});

  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      animationController: animationController,
      start: 0.6,
      image: 'assets/onboarding/welcome.webp',
      title: 'onbwelcome'.tr,
      text: 'onbletbegdesc'.tr,
    );
  }
}
