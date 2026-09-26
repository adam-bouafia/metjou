import 'package:flutter/material.dart';
import 'package:metjou/core/theme/app_theme.dart';

const onboardingPrimary = AppColors.primary;

/// Matches the background baked into the onboarding illustrations.
const onboardingBackground = Color(0xffF4EAE2);
const _textColor = Color(0xff132137);

/// Aspect ratio of the onboarding illustrations (852x480).
const _illustrationRatio = 852 / 480;

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
        final width = constraints.maxWidth - 48;
        final illustrationWidth =
            (constraints.maxHeight * 0.42 * _illustrationRatio).clamp(
              0.0,
              width,
            );
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    image,
                    width: illustrationWidth,
                    height: illustrationWidth / _illustrationRatio,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    gaplessPlayback: true,
                  ),
                ),
                const SizedBox(height: 32),
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
                if (action != null) ...[const SizedBox(height: 28), action!],
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
