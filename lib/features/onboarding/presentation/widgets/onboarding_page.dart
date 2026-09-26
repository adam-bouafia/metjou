import 'package:flutter/material.dart';
import 'package:metjou/core/theme/app_theme.dart';

const onboardingPrimary = AppColors.primary;

/// Matches the background baked into the onboarding illustrations.
const onboardingBackground = Color(0xffF4EAE2);
const _textColor = Color(0xff132137);

/// The illustrations are 852x480 (1.78); allow cropping the sides down to
/// this ratio so they can be taller on narrow phones.
const _minRatio = 1.45;

/// One onboarding step: illustration, explanation and an optional action.
/// Sizes follow the available space, so it fits small and large phones and
/// scrolls when the text is scaled up.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.image,
    required this.text,
    this.title,
    this.action,
  });

  final String image;
  final String text;
  final String? title;

  /// Extra control under the text, such as a permission button.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Edge to edge: the illustration background matches the screen, so
        // it blends in. On tall screens it may crop up to ~18% at the sides
        // to grow taller, never more than half of the available height.
        final width = constraints.maxWidth;
        final height = (width / _minRatio).clamp(
          0.0,
          constraints.maxHeight * 0.5,
        );
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  image,
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  gaplessPlayback: true,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      if (title != null) ...[
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            title!,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.45,
                            color: _textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (action != null) ...[
                        const SizedBox(height: 28),
                        action!,
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Secondary action on a page, e.g. granting a permission. The main
/// "Next" button lives in the bottom bar.
class OnboardingActionButton extends StatelessWidget {
  const OnboardingActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: onboardingPrimary,
        side: const BorderSide(color: onboardingPrimary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}
