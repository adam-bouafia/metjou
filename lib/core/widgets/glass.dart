import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:metjou/core/theme/app_theme.dart';

/// Frosted-glass panel: blurs what is behind it, with a translucent (or
/// tinted) fill, a light sheen, a thin light border and a soft shadow.
/// Joins the nearest [BackdropGroup], so many panels share one blur pass.
///
/// Dark mode uses deep, strongly tinted glass; light mode uses clear
/// glassmorphism (mostly see-through, white sheen and edge) so the
/// colourful [GlassBackground] shows through.
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

    final Color shadow;
    final Decoration fill;
    final Color border;
    if (dark) {
      shadow = (tint?.last ?? Colors.black).withValues(alpha: 0.25);
      border = Colors.white.withValues(alpha: 0.12);
      fill = BoxDecoration(
        gradient: tint == null
            ? null
            : LinearGradient(
                colors: [for (final c in tint) c.withValues(alpha: 0.82)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: tint == null
            ? scheme.surfaceContainerLowest.withValues(alpha: 0.45)
            : null,
      );
    } else {
      shadow = (tint?.last ?? Latte.mauve).withValues(
        alpha: tint == null ? 0.12 : 0.28,
      );
      border = Colors.white.withValues(alpha: 0.7);
      fill = BoxDecoration(
        gradient: LinearGradient(
          colors: tint == null
              ? [
                  Colors.white.withValues(alpha: 0.42),
                  Colors.white.withValues(alpha: 0.18),
                ]
              : [for (final c in tint) c.withValues(alpha: 0.58)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [
          BoxShadow(color: shadow, blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: BackdropFilter.grouped(
          filter: ImageFilter.blur(
            sigmaX: dark ? 14 : 18,
            sigmaY: dark ? 14 : 18,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              child: Ink(
                decoration: fill,
                child: DecoratedBox(
                  // Light sheen from the top-left, like light on glass.
                  decoration: BoxDecoration(
                    borderRadius: shape,
                    border: Border.all(color: border, width: dark ? 1 : 1.2),
                    gradient: dark
                        ? null
                        : LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.35),
                              Colors.white.withValues(alpha: 0),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.center,
                          ),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft, blurred colour shapes behind a screen, so glass panels on top of
/// it have something to blur. Light mode gets a vivid pastel gradient for
/// glassmorphism; dark mode keeps faint shapes on the dark base. Also
/// provides the [BackdropGroup].
class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    Widget blob(Color color, double size, double alpha) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: alpha),
      ),
    );
    final shapes = dark
        ? [
            Positioned(
              top: -40,
              left: -60,
              child: blob(Latte.mauve, 260, 0.22),
            ),
            Positioned(
              top: 320,
              right: -80,
              child: blob(Latte.pink, 240, 0.22),
            ),
            Positioned(
              bottom: 60,
              left: -40,
              child: blob(Latte.teal, 220, 0.22),
            ),
          ]
        : [
            Positioned(
              top: -60,
              left: -70,
              child: blob(Latte.mauve, 280, 0.45),
            ),
            Positioned(
              top: 180,
              right: -90,
              child: blob(Latte.pink, 260, 0.42),
            ),
            Positioned(
              top: 520,
              left: -50,
              child: blob(const Color(0xff04a5e5), 240, 0.32),
            ),
            Positioned(
              bottom: -40,
              right: -30,
              child: blob(Latte.peach, 200, 0.25),
            ),
          ];
    return BackdropGroup(
      child: Stack(
        children: [
          if (!dark)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xffEEE6FF),
                      Color(0xffFDEAF4),
                      Color(0xffE3F2FD),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: dark ? 60 : 50,
                  sigmaY: dark ? 60 : 50,
                ),
                child: Stack(children: shapes),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
