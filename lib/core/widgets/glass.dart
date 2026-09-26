import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:metjou/core/theme/app_theme.dart';

/// Frosted-glass panel: blurs what is behind it, with a translucent fill
/// and a thin light border. Pass [colors] for a tinted gradient panel.
/// Joins the nearest [BackdropGroup], so many panels share one blur pass.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.colors,
    this.radius = 20,
    this.onTap,
  });

  final Widget child;
  final List<Color>? colors;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final shape = BorderRadius.circular(radius);
    final tint = colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [
          BoxShadow(
            color: (tint?.last ?? Colors.black).withValues(
              alpha: dark ? 0.25 : 0.14,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: BackdropFilter.grouped(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: shape,
                  gradient: tint == null
                      ? null
                      : LinearGradient(
                          colors: [
                            for (final c in tint) c.withValues(alpha: 0.82),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: tint == null
                      ? scheme.surfaceContainerLowest.withValues(
                          alpha: dark ? 0.45 : 0.6,
                        )
                      : null,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: dark ? 0.12 : 0.45),
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft, blurred colour shapes behind a screen, so glass panels on top of
/// it have something to blur. Also provides the [BackdropGroup].
class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final alpha = dark ? 0.22 : 0.28;
    Widget blob(Color color, double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: alpha),
      ),
    );
    return BackdropGroup(
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Stack(
                  children: [
                    Positioned(
                      top: -40,
                      left: -60,
                      child: blob(Latte.mauve, 260),
                    ),
                    Positioned(
                      top: 320,
                      right: -80,
                      child: blob(Latte.pink, 240),
                    ),
                    Positioned(
                      bottom: 60,
                      left: -40,
                      child: blob(Latte.teal, 220),
                    ),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
