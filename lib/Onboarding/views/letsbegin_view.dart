import 'package:flutter/material.dart';
import 'package:metjou/Utility/app_locale.dart';
import 'package:metjou/Utility/language_picker.dart';
import 'package:metjou/Onboarding/views/onboarding_page.dart';

class Letsbegin extends StatefulWidget {
  final AnimationController animationController;

  const Letsbegin({super.key, required this.animationController});

  @override
  _LetsbeginState createState() => _LetsbeginState();

}

class _LetsbeginState extends State<Letsbegin> {
  @override
  Widget build(BuildContext context) {
    final _introductionanimation =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(0.0, -1.0))
            .animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Interval(
        0.0,
        0.2,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    return SlideTransition(
      position: _introductionanimation,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/onboarding/introduction_image.webp',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "MetJou",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.onbIntro,
                style: TextStyle(fontSize: 16, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: onboardingPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  onPressed: () => widget.animationController.animateTo(0.2),
                  child: Text(context.l10n.onbBegin, style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: onboardingPrimary,
                    side: const BorderSide(color: onboardingPrimary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  onPressed: () => showLanguagePicker(context),
                  icon: const Icon(Icons.language),
                  label: Text(context.l10n.chooseLanguage, style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
