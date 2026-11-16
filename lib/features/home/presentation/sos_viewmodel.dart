import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metjou/core/services/background_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SosState {
  const SosState({this.alerted = false});

  /// Whether an SOS alert is active right now.
  final bool alerted;
}

/// Whether an SOS alert is running. An alert can also be sent by shaking,
/// the Quick Settings tile, the widget or a shortcut, so [refresh] re-reads
/// it from storage rather than trusting only what this ViewModel set.
class SosViewModel extends Notifier<SosState> {
  @override
  SosState build() {
    refresh();
    return const SosState();
  }

  Future<void> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    state = SosState(alerted: prefs.getBool("alerted") ?? false);
  }

  /// Sends the SOS or the all-clear SMS. Returns how many contacts got it;
  /// zero means nothing was sent, and the alert is turned back off.
  Future<int> setAlert(
    bool isAlert,
    String smsText, {
    bool withLocation = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("alerted", isAlert);
    state = SosState(alerted: isAlert);
    final sent = await BackgroundServices.sendSosAlert(
      smsText,
      withLocation: withLocation,
    );
    if (sent == 0) {
      await prefs.setBool("alerted", false);
      state = const SosState(alerted: false);
    }
    return sent;
  }
}

final sosViewModelProvider = NotifierProvider<SosViewModel, SosState>(
  SosViewModel.new,
);
