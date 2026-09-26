import 'package:animations/animations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:metjou/Legal/policy_dialog.dart';
import 'package:metjou/Utility/app_locale.dart';

class TermsOfUse extends StatelessWidget {
  const TermsOfUse({super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: "${context.l10n.termsPrefix}\n",
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: context.l10n.termsLink,
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xffB271AA)),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  showModal(
                    context: context,
                    configuration: FadeScaleTransitionConfiguration(),
                    builder: (context) {
                      return PolicyDialog(
                        mdFileName: 'terms_and_conditions.md',
                      );
                    },
                  );
                },
            ),
            TextSpan(text: " ${context.l10n.termsAnd} "),
            TextSpan(
              text: context.l10n.privacyLink,
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xffB271AA)),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return PolicyDialog(
                        mdFileName: 'privacy_policy.md',
                      );
                    },
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}