import 'dart:ui';

import 'package:flutter/material.dart';

/// Space the page content should leave free at the bottom for the dock.
const glassDockClearance = 112.0;

/// Floating bottom bar that blurs the content scrolling behind it.
class GlassDock extends StatelessWidget {
  const GlassDock({
    super.key,
    required this.currentPage,
    required this.onSelect,
    required this.center,
  });

  final int currentPage;
  final ValueChanged<int> onSelect;

  /// Widget in the middle of the dock (the SOS button).
  final Widget center;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _DockItem(
                      icon: Icons.home_rounded,
                      selected: currentPage == 0,
                      onTap: () => onSelect(0),
                    ),
                  ),
                  center,
                  Expanded(
                    child: _DockItem(
                      icon: Icons.contacts_rounded,
                      selected: currentPage == 1,
                      onTap: () => onSelect(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: AnimatedScale(
            scale: selected ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: Icon(
              icon,
              size: 28,
              color: selected
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
