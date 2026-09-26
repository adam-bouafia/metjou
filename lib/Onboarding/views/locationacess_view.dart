import 'package:flutter/material.dart';
import 'package:metjou/Utility/app_locale.dart';
import 'package:metjou/Onboarding/views/onboarding_page.dart';
import 'package:permission_handler/permission_handler.dart';

class Locationaccess extends StatelessWidget {
  const Locationaccess({super.key, required this.animationController});

  final AnimationController animationController;

  /// Background location has to be requested after foreground location.
  Future<void> _requestLocation() async {
    if (await Permission.location.request().isGranted) {
      await Permission.locationAlways.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      animationController: animationController,
      start: 0.0,
      enterFromBottom: true,
      image: 'assets/onboarding/Clip.webp',
      text: context.l10n.onbLocationText,
      buttonLabel: context.l10n.onbLocationButton,
      onPressed: _requestLocation,
    );
  }
}
