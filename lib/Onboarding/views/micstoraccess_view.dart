import 'package:flutter/material.dart';
import 'package:metjou/Utility/app_locale.dart';
import 'package:metjou/Onboarding/views/onboarding_page.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactAccess extends StatelessWidget {
  const ContactAccess({super.key, required this.animationController});

  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      animationController: animationController,
      start: 0.2,
      image: 'assets/onboarding/care_image.webp',
      text: context.l10n.onbMicText,
      buttonLabel: context.l10n.onbMicButton,
      onPressed: () => [Permission.microphone, Permission.notification].request(),
    );
  }
}
