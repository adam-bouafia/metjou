import 'package:flutter/material.dart';
import 'package:metjou/core/widgets/quick_exit_button.dart';
import 'package:metjou/features/resources/data/resources.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/services/phone_call.dart';
import 'package:url_launcher/url_launcher.dart';

/// Detail page of a support resource: what it is, call and website.
class ArticleDesc extends StatelessWidget {
  const ArticleDesc({super.key, required this.resource});

  final SafetyResource resource;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(actions: const [QuickExitButton()]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Hero(
            tag: resource.url,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: ResourceBadge(resource: resource, size: 72),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            resource.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            resource.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 32),
          if (resource.phone != null) ...[
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: resource.colors.last,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => callNumber(resource.phone!),
              icon: const Icon(Icons.call),
              label: Text(
                l10n.callNumber(resource.phone!),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: resource.colors.last,
              side: BorderSide(color: resource.colors.last),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => launchUrl(
              Uri.parse(resource.url),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.openWebsite, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

/// Rounded gradient square with the resource icon.
class ResourceBadge extends StatelessWidget {
  const ResourceBadge({super.key, required this.resource, required this.size});

  final SafetyResource resource;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 4),
        gradient: LinearGradient(
          colors: resource.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(resource.icon, color: Colors.white, size: size / 2),
    );
  }
}
