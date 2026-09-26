import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';

/// Round SOS button with a pulsing ring: slow and soft when idle, fast and
/// red while an alert is active.
class SosButton extends StatefulWidget {
  const SosButton({super.key, required this.alerted, required this.onPressed});

  final bool alerted;
  final VoidCallback onPressed;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: _period,
  )..repeat();

  Duration get _period => widget.alerted
      ? const Duration(milliseconds: 900)
      : const Duration(milliseconds: 2400);

  @override
  void didUpdateWidget(SosButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alerted != widget.alerted) {
      _pulse
        ..duration = _period
        ..repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 64.0;
    final colors = widget.alerted
        ? const [Color(0xffFF5A5A), Color(0xffD32F2F)]
        : const [Color(0xffFDB09A), Color(0xffF4796B)];
    return Semantics(
      button: true,
      label: widget.alerted ? context.l10n.stop : 'SOS',
      child: SizedBox(
        width: size + 24,
        height: size + 24,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) {
                final t = Curves.easeOut.transform(_pulse.value);
                return Container(
                  width: size + 24 * t,
                  height: size + 24 * t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.last.withValues(alpha: 0.35 * (1 - t)),
                  ),
                );
              },
            ),
            Material(
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              elevation: 6,
              shadowColor: colors.last,
              child: InkWell(
                onTap: widget.onPressed,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: widget.alerted
                        ? Text(
                            context.l10n.stop,
                            key: const ValueKey('stop'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Image.asset(
                            "assets/icons/alert.webp",
                            key: const ValueKey('sos'),
                            height: 34,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
