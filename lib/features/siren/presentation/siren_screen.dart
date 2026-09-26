import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/services/device.dart';

/// Loud two-tone siren at full volume, a flashing screen and a strobing
/// flashlight, to draw attention. Volume and flashlight are restored when
/// the screen closes.
class SirenScreen extends StatefulWidget {
  const SirenScreen({super.key});

  @override
  State<SirenScreen> createState() => _SirenScreenState();
}

class _SirenScreenState extends State<SirenScreen> {
  final _player = AudioPlayer();
  Timer? _strobe;
  bool _bright = false;
  bool _sound = true;
  bool _flash = true;

  @override
  void initState() {
    super.initState();
    _startSound();
    _strobe = Timer.periodic(const Duration(milliseconds: 250), (_) {
      setState(() => _bright = !_bright);
      if (_flash) Device.setTorch(_bright);
    });
  }

  Future<void> _startSound() async {
    await Device.boostVolume();
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('sounds/siren.ogg'), volume: 1);
  }

  Future<void> _setSound(bool on) async {
    setState(() => _sound = on);
    on ? await _startSound() : await _player.stop();
  }

  void _setFlash(bool on) {
    setState(() => _flash = on);
    if (!on) Device.setTorch(false);
  }

  @override
  void dispose() {
    _strobe?.cancel();
    _player.dispose();
    Device.setTorch(false);
    Device.restoreVolume();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // No flashing screen for people who turned animations off.
    final flashing = !MediaQuery.disableAnimationsOf(context);
    final background = flashing && _bright
        ? Colors.white
        : const Color(0xffd20f39);
    final foreground = flashing && _bright
        ? const Color(0xffd20f39)
        : Colors.white;
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _Toggle(
                      label: l10n.sirenSound,
                      icon: Icons.volume_up,
                      value: _sound,
                      color: foreground,
                      onChanged: _setSound,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Toggle(
                      label: l10n.sirenFlash,
                      icon: Icons.flashlight_on,
                      value: _flash,
                      color: foreground,
                      onChanged: _setFlash,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox.square(
                dimension: 220,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: foreground,
                    foregroundColor: background,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.sirenStop,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.icon,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: value ? 2 : 1),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: () => onChanged(!value),
      icon: Icon(value ? icon : Icons.block),
      label: Text(label),
    );
  }
}
