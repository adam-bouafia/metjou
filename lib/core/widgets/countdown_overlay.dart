import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/services/alert_countdown.dart';

/// Full-screen countdown with a large Cancel button, shown above every
/// screen while an alert countdown runs.
class CountdownOverlay extends StatelessWidget {
  const CountdownOverlay({super.key, required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.error.withValues(alpha: 0.94),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Text(
                  "$seconds",
                  key: ValueKey(seconds),
                  style: TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    color: scheme.onError,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.countdownTitle(seconds),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, color: scheme.onError),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.countdownBody,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: scheme.onError),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.onError,
                    foregroundColor: scheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  onPressed: AlertCountdown.cancel,
                  child: Text(
                    context.l10n.cancel,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
