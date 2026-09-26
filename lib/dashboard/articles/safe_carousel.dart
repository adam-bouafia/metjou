import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:metjou/dashboard/articles/article_desc.dart';
import 'package:metjou/dashboard/articles/resources.dart';

/// Home screen carousel of support resources.
class SafeCarousel extends StatelessWidget {
  const SafeCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final resources = safetyResources(context);
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 6),
        aspectRatio: 2.2,
        enlargeCenterPage: true,
      ),
      items: [
        for (final r in resources)
          Card(
            elevation: 5,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: InkWell(
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => ArticleDesc(resource: r))),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: r.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(r.icon, color: Colors.white, size: 36),
                    const Spacer(),
                    Text(
                      r.title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (r.phone != null)
                      Text(r.phone!, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
