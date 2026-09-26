import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/navigation/app_navigator.dart';
import 'package:metjou/core/services/background_services.dart';
import 'package:metjou/features/fake_call/presentation/fake_call_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _nameKey = "fakeCallName";

abstract final class FakeCallService {
  static Timer? _timer;

  static Future<String> callerName() async {
    final saved = (await SharedPreferences.getInstance()).getString(_nameKey);
    return saved ?? (await backgroundLocalizations()).fakeCallDefaultName;
  }

  static Future<void> setCallerName(String name) async =>
      (await SharedPreferences.getInstance()).setString(_nameKey, name);

  /// Rings after [delay]: on screen when the app is open, otherwise as a
  /// call notification that opens the ringing screen.
  static Future<void> schedule(Duration delay) async {
    _timer?.cancel();
    if (delay == Duration.zero) return ring();
    _timer = Timer(delay, () async {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        await ring();
      } else {
        final l10n = await backgroundLocalizations();
        await BackgroundServices.showFakeCallNotification(
          title: l10n.fakeCallFrom(await callerName()),
          body: l10n.fakeCallMobile,
        );
      }
    });
  }

  static Future<void> ring() async =>
      pushScreen(FakeCallScreen(caller: await callerName()));
}
