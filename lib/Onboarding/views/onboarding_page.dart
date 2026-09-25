import 'package:flutter/material.dart';

const onboardingPrimary = Color(0xffB271AA);
const _textColor = Color(0xff132137);

/// Space kept free at the bottom for the page dots, next button and the
/// terms line drawn by [CenterNextButton].
const onboardingBottomInset = 170.0;

/// One onboarding step: illustration, explanation and an optional
/// permission button, with the same spacing on every page.
///
/// The page slides in during [start]..[start]+0.2 of [animationController]
/// and slides out to the left during the following 0.2.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.animationController,
    required this.start,
    required this.image,
    required this.text,
    this.title,
    this.buttonLabel,
    this.onPressed,
    this.enterFromBottom = false,
  });

  final AnimationController animationController;
  final double start;
  final String image;
  final String text;
  final String? title;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final bool enterFromBottom;

  Animation<Offset> _slide(Offset begin, Offset end, double from) =>
      Tween<Offset>(begin: begin, end: end).animate(CurvedAnimation(
        parent: animationController,
        curve: Interval(from, from + 0.2, curve: Curves.fastOutSlowIn),
      ));

  @override
  Widget build(BuildContext context) {
    final enter = _slide(
        enterFromBottom ? const Offset(0, 1) : const Offset(1, 0), Offset.zero, start);
    final exit = _slide(Offset.zero, const Offset(-1, 0), start + 0.2);

    return SlideTransition(
      position: enter,
      child: SlideTransition(
        position: exit,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 64, 32, onboardingBottomInset),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: Image.asset(image, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 32),
                if (title != null) ...[
                  Text(
                    title!,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold, color: _textColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  text,
                  style: const TextStyle(fontSize: 16, height: 1.4, color: _textColor),
                  textAlign: TextAlign.center,
                ),
                if (buttonLabel != null) ...[
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: onPressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: onboardingPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    ),
                    child: Text(
                      buttonLabel!,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
