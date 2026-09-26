import 'package:flutter/material.dart';
import 'package:metjou/Dashboard/Articles/ArticleDesc.dart';
import 'package:metjou/Dashboard/Articles/resources.dart';
import 'package:metjou/Utility/app_locale.dart';

/// Full list of support resources.
class AllArticles extends StatelessWidget {
  const AllArticles({super.key});

  @override
  Widget build(BuildContext context) {
    final resources = safetyResources(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.resourcesTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: resources.length,
        separatorBuilder: (_, _) => const Divider(indent: 88, height: 1),
        itemBuilder: (context, index) {
          final r = resources[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Hero(tag: r.url, child: ResourceBadge(resource: r, size: 56)),
            title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(r.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => ArticleDesc(resource: r))),
          );
        },
      ),
    );
  }
}
