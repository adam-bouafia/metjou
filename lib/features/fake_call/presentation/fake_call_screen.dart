import 'dart:async';

import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/services/device.dart';
import 'package:vibration/vibration.dart';

/// Looks like an incoming phone call: the phone's own ringtone, vibration,
/// then an in-call screen with a running timer.
class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key, required this.caller});

  final String caller;

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();
  DateTime? _answeredAt;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    Device.startRingtone();
    Vibration.vibrate(pattern: [0, 800, 600, 800, 600, 800], repeat: 0);
  }

  @override
  void dispose() {
    _stopRinging();
    _clock?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _stopRinging() {
    Device.stopRingtone();
    Vibration.cancel();
  }

  void _answer() {
    _stopRinging();
    _pulse.stop();
    setState(() => _answeredAt = DateTime.now());
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  String get _duration {
    final d = DateTime.now().difference(_answeredAt!);
    return "${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  String get _initials => widget.caller
      .split(RegExp(r"\s+"))
      .where((p) => p.isNotEmpty)
      .take(2)
      .map((p) => p.characters.first.toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final answered = _answeredAt != null;
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff1f2a3a), Color(0xff0e141d)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 72),
                Text(
                  answered ? _duration : l10n.fakeCallMobile,
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.caller,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 36),
                ),
                const SizedBox(height: 48),
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) {
                    final t = Curves.easeOut.transform(_pulse.value);
                    return Container(
                      padding: EdgeInsets.all(answered ? 0 : 24 * t),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(
                          alpha: answered ? 0 : 0.15 * (1 - t),
                        ),
                      ),
                      child: child,
                    );
                  },
                  child: CircleAvatar(
                    radius: 64,
                    backgroundColor: const Color(0xff4b5d75),
                    child: Text(
                      _initials,
                      style: const TextStyle(color: Colors.white, fontSize: 44),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 64),
                  child: answered
                      ? _RoundButton(
                          color: const Color(0xffe53935),
                          icon: Icons.call_end,
                          label: l10n.fakeCallEnd,
                          onTap: () => Navigator.pop(context),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _RoundButton(
                              color: const Color(0xffe53935),
                              icon: Icons.call_end,
                              label: l10n.fakeCallDecline,
                              onTap: () => Navigator.pop(context),
                            ),
                            _RoundButton(
                              color: const Color(0xff43a047),
                              icon: Icons.call,
                              label: l10n.fakeCallAccept,
                              onTap: _answer,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox.square(
              dimension: 72,
              child: Icon(icon, color: Colors.white, size: 32),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
