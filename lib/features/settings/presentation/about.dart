import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/features/settings/presentation/widgets/about_card.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});
  void showLicences(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationVersion: "2.0.0",
      applicationIcon: Image.asset("assets/logoss.webp", height: 50),
      applicationName: "MetJou",
      applicationLegalese: context.l10n.aboutLegalese,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.about, style: TextStyle(fontSize: 26)),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () => showLicences(context),
              child: Icon(
                Icons.info_outline,
                size: 26,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          AboutCard(
            desc: context.l10n.aboutDescription,
            subtitle: context.l10n.tagline,
            title: "MetJou",
            sizeFactor: 1.8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: ListTile(
                onTap: () {
                  showLicences(context);
                },
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHigh,
                  child: Center(
                    child: Image.asset("assets/card.webp", height: 30),
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded),
                title: Text(context.l10n.licenses),
              ),
            ),
          ),
          SizedBox(height: 50),
          Row(
            children: [
              Expanded(child: Divider(indent: 10, endIndent: 10)),
              Text(context.l10n.copyright),
              Expanded(child: Divider(indent: 10, endIndent: 10)),
            ],
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
