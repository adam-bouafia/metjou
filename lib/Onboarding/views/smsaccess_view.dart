import 'package:flutter/material.dart';
import 'package:metjou/Utility/app_locale.dart';
import 'package:metjou/Onboarding/views/onboarding_page.dart';
import 'package:permission_handler/permission_handler.dart';

class Smsaccess extends StatelessWidget {
  const Smsaccess({super.key, required this.animationController});

  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      animationController: animationController,
      start: 0.4,
      image: 'assets/onboarding/mood_dairy_image.webp',
      text: context.l10n.onbSmsText,
      buttonLabel: context.l10n.onbSmsButton,
      onPressed: () => [Permission.sms, Permission.phone].request(),
    );
  }
}
