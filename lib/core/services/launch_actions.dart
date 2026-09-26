import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/navigation/app_navigator.dart';
import 'package:metjou/core/services/alert_countdown.dart';
import 'package:metjou/core/services/background_services.dart';
import 'package:metjou/core/services/device.dart';
import 'package:metjou/features/fake_call/data/fake_call_service.dart';
import 'package:metjou/features/siren/presentation/siren_screen.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles the Quick Settings tile, the home screen widget and the app
/// icon shortcuts. SOS always goes through the countdown, so an accidental
/// tap can still be cancelled.
abstract final class LaunchActions {
  static Future<void> init() async {
    await Device.listenForLaunchActions(handle);
    final l10n = await backgroundLocalizations();
    const quickActions = QuickActions();
    await quickActions.initialize(handle);
    await quickActions.setShortcutItems([
      ShortcutItem(
        type: LaunchAction.sos,
        localizedTitle: 'SOS',
        icon: 'ic_shortcut_sos',
      ),
      ShortcutItem(
        type: LaunchAction.fakeCall,
        localizedTitle: l10n.fakeCall,
        icon: 'ic_shortcut_call',
      ),
      ShortcutItem(
        type: LaunchAction.siren,
        localizedTitle: l10n.siren,
        icon: 'ic_shortcut_siren',
      ),
    ]);
  }

  static Future<void> handle(String action) async {
    switch (action) {
      case LaunchAction.sos:
        await AlertCountdown.start(_sendSos);
      case LaunchAction.fakeCall:
        await FakeCallService.ring();
      case LaunchAction.siren:
        await pushScreen(const SirenScreen());
    }
  }

  static Future<void> _sendSos() async {
    final l10n = await backgroundLocalizations();
    if (await BackgroundServices.sendSosAlert(l10n.smsSos) > 0) {
      await (await SharedPreferences.getInstance()).setBool("alerted", true);
    }
  }
}
