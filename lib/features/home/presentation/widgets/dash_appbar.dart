import 'package:flutter/material.dart';
import 'package:metjou/core/widgets/pin_guard.dart';
import 'package:metjou/core/widgets/quick_exit_button.dart';
import 'package:metjou/features/settings/presentation/settings_screen.dart';
import 'package:metjou/core/localization/app_locale.dart';

class DashAppbar extends StatelessWidget {
  const DashAppbar({super.key, required this.onTap, required this.quoteIndex});

  final VoidCallback onTap;
  final int quoteIndex;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        'MetJou',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      subtitle: GestureDetector(
        onTap: onTap,
        child: Text(
          [
            context.l10n.slogan1,
            context.l10n.slogan2,
            context.l10n.slogan3,
          ][quoteIndex],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.width * 0.06,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const QuickExitButton(),
          Card(
            elevation: 4,
            shape: CircleBorder(),
            child: InkWell(
              onTap: () async {
                if (!await confirmPin(context) || !context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset("assets/settings.webp", height: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
