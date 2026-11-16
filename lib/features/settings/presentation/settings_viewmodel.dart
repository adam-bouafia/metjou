import 'package:audio_background_record/audio_background_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metjou/core/services/alert_countdown.dart';
import 'package:metjou/core/services/background_services.dart';
import 'package:metjou/core/services/discreet_mode.dart';
import 'package:metjou/core/services/fall_detection.dart';
import 'package:metjou/core/services/low_battery.dart';
import 'package:metjou/core/widgets/pin_guard.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _unset = Object();

class SettingsState {
  const SettingsState({
    this.pin = noPin,
    this.discreet = false,
    this.safeShake = false,
    this.audioRecord = false,
    this.recordFolder,
    this.fallDetection = false,
    this.lowBattery = false,
    this.countdownSeconds = defaultCountdownSeconds,
  });

  final int pin;
  final bool discreet;
  final bool safeShake;
  final bool audioRecord;

  /// Picked recordings folder, or null for the app's private folder.
  final String? recordFolder;
  final bool fallDetection;
  final bool lowBattery;
  final int countdownSeconds;

  SettingsState copyWith({
    int? pin,
    bool? discreet,
    bool? safeShake,
    bool? audioRecord,
    Object? recordFolder = _unset,
    bool? fallDetection,
    bool? lowBattery,
    int? countdownSeconds,
  }) => SettingsState(
    pin: pin ?? this.pin,
    discreet: discreet ?? this.discreet,
    safeShake: safeShake ?? this.safeShake,
    audioRecord: audioRecord ?? this.audioRecord,
    recordFolder: recordFolder == _unset
        ? this.recordFolder
        : recordFolder as String?,
    fallDetection: fallDetection ?? this.fallDetection,
    lowBattery: lowBattery ?? this.lowBattery,
    countdownSeconds: countdownSeconds ?? this.countdownSeconds,
  );
}

/// Loads every setting once instead of each toggle re-fetching its own
/// value with a fresh `FutureBuilder` on every rebuild.
class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    refresh();
    return const SettingsState();
  }

  Future<void> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final folder = await AudioBackgroundRecord.getInstance()
        .getRecordingDestination();
    state = SettingsState(
      pin: prefs.getInt('pin') ?? noPin,
      discreet: await DiscreetMode.isEnabled(),
      safeShake: prefs.getBool("smsSend") ?? false,
      audioRecord: prefs.getBool("bgRecord") ?? false,
      recordFolder: folder,
      fallDetection: await FallDetection.isEnabled(),
      lowBattery: await LowBatteryAlert.isEnabled(),
      countdownSeconds:
          prefs.getInt(countdownSecondsKey) ?? defaultCountdownSeconds,
    );
  }

  Future<void> setDiscreet(bool on) async {
    await DiscreetMode.setEnabled(on);
    BackgroundServices.discreet = on;
    state = state.copyWith(discreet: on);
  }

  Future<void> setSafeShake(bool on) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("smsSend", on);
    await BackgroundServices.setSafeShake(on);
    state = state.copyWith(safeShake: on);
  }

  Future<void> setAudioRecord(bool on) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("bgRecord", on);
    await BackgroundServices.setAudioRecording(on);
    state = state.copyWith(audioRecord: on);
  }

  Future<void> setFallDetection(bool on) async {
    await FallDetection.setEnabled(on);
    state = state.copyWith(fallDetection: on);
  }

  Future<void> setLowBattery(bool on) async {
    await LowBatteryAlert.setEnabled(on);
    state = state.copyWith(lowBattery: on);
  }

  Future<void> setCountdown(int seconds) async {
    await (await SharedPreferences.getInstance()).setInt(
      countdownSecondsKey,
      seconds,
    );
    state = state.copyWith(countdownSeconds: seconds);
  }

  Future<void> setRecordFolder(String? folder) async {
    final recorder = AudioBackgroundRecord.getInstance();
    if (folder == null) {
      await recorder.resetDirectory();
    }
    state = state.copyWith(recordFolder: folder);
  }

  /// Turns the PIN off directly; setting one goes through ChangePinScreen,
  /// after which the caller calls [refresh].
  Future<void> turnPinOff() async {
    await (await SharedPreferences.getInstance()).setInt('pin', noPin);
    state = state.copyWith(pin: noPin);
  }
}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(SettingsViewModel.new);
