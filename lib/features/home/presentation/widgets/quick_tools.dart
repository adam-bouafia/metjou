import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/theme/app_theme.dart';
import 'package:metjou/features/fake_call/presentation/fake_call_sheet.dart';

/// Row of one-tap tools on the home screen.
class QuickTools extends StatelessWidget {
  const QuickTools({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tools = [
      (
        Icons.phone_in_talk_rounded,
        l10n.fakeCall,
        const [Latte.green, Latte.teal],
        () => showFakeCallSheet(context),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (final (icon, label, colors, onTap) in tools)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _ToolTile(
                  icon: icon,
                  label: label,
                  colors: colors,
                  onTap: onTap,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          height: 84,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
