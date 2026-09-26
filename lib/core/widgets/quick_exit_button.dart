import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:url_launcher/url_launcher.dart';

/// A harmless page to land on, like the quick-exit buttons on Dutch
/// domestic violence websites.
final _neutralPage = Uri.parse('https://www.buienradar.nl/');

/// Opens the weather in the browser and closes MetJou in one tap, for when
/// someone looks over the user's shoulder.
Future<void> quickExit() async {
  await launchUrl(_neutralPage, mode: LaunchMode.externalApplication);
  await SystemNavigator.pop();
}

class QuickExitButton extends StatelessWidget {
  const QuickExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: context.l10n.quickExitHint,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: scheme.error,
          visualDensity: VisualDensity.compact,
        ),
        onPressed: quickExit,
        icon: const Icon(Icons.exit_to_app, size: 20),
        label: Text(context.l10n.quickExit),
      ),
    );
  }
}
