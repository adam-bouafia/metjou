import 'package:audio_background_record/audio_background_record.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metjou/core/theme/app_theme.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metjou/features/settings/presentation/about.dart';
import 'package:metjou/features/settings/presentation/change_pin.dart';
import 'package:metjou/core/services/alert_countdown.dart';
import 'package:metjou/core/services/background_services.dart';
import 'package:metjou/core/services/discreet_mode.dart';
import 'package:metjou/core/services/fall_detection.dart';
import 'package:metjou/core/services/low_battery.dart';
import 'package:metjou/core/widgets/pin_guard.dart';
import 'package:metjou/features/legal/presentation/policy_dialog.dart';
import 'package:metjou/features/medical_id/presentation/medical_id_screen.dart';
import 'package:metjou/core/localization/language_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool switchValue = false;
  bool switchAudioRecord = false;

  /// Picked recordings folder, or null for the app's private folder.
  String? recordFolder;

  @override
  void initState() {
    super.initState();
    checkService();
  }

  static const _recordDurations = [
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(hours: 1),
  ];

  Future<void> _selectRecordDuration(BuildContext context) async {
    final selected = await showDialog<Duration>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l10n.audioRecordLength),
        children: [
          for (final d in _recordDurations)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, d),
              child: Text(context.l10n.minutes(d.inMinutes)),
            ),
        ],
      ),
    );
    if (selected != null) {
      await AudioBackgroundRecord.getInstance().configure(
        maxDurationInMillis: selected.inMilliseconds,
      );
    }
  }

  Future<int> checkPIN() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int pin = (prefs.getInt('pin') ?? -1111);
    return pin;
  }

  /// Lets the user pick any folder through Android's folder picker, or go
  /// back to the app's private folder.
  Future<void> _selectRecordFolder(BuildContext context) async {
    final recorder = AudioBackgroundRecord.getInstance();
    final choice = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: Text(context.l10n.audioRecordFolderChoose),
              onTap: () => Navigator.pop(context, true),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(context.l10n.audioRecordFolderReset),
              onTap: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    if (choice) {
      final folder = await recorder.pickDirectory();
      if (folder == null || !mounted) return;
      setState(() => recordFolder = folder);
    } else {
      await recorder.resetDirectory();
      if (mounted) setState(() => recordFolder = null);
    }
  }

  Future<void> _selectCountdown(BuildContext context, int current) async {
    final seconds = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l10n.countdownSetting),
        children: [
          RadioGroup<int>(
            groupValue: current,
            onChanged: (s) => Navigator.pop(context, s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final s in [0, 3, 5, 10])
                  RadioListTile<int>(
                    value: s,
                    title: Text(
                      s == 0 ? context.l10n.off : context.l10n.seconds(s),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (seconds == null) return;
    await (await SharedPreferences.getInstance()).setInt(
      countdownSecondsKey,
      seconds,
    );
    if (mounted) setState(() {});
  }

  Future<void> _setDiscreet(BuildContext context, bool on) async {
    if (on) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.discreetConfirmTitle),
          content: Text(context.l10n.discreetConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.turnOn),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await DiscreetMode.setEnabled(on);
    BackgroundServices.discreet = on;
    if (mounted) setState(() {});
  }

  /// Without a PIN: create one. With a PIN: change it or turn it off; turning
  /// it off asks for the current PIN first.
  Future<void> _onPinTap(BuildContext context, int pin) async {
    Future<void> change() => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChangePinScreen(pin: pin)),
    );
    if (pin == noPin) {
      await change();
    } else {
      final l10n = context.l10n;
      final turnOff = await showModalBottomSheet<bool>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.password),
                title: Text(l10n.changePin),
                onTap: () => Navigator.pop(context, false),
              ),
              ListTile(
                leading: Icon(
                  Icons.lock_open,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(l10n.pinTurnOff),
                onTap: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ),
      );
      if (turnOff == null || !context.mounted) return;
      if (!turnOff) {
        await change();
      } else if (await confirmPin(context)) {
        await (await SharedPreferences.getInstance()).setInt('pin', noPin);
        Fluttertoast.showToast(msg: l10n.pinTurnedOff);
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _sendTestAlert(BuildContext context) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.testAlert),
        content: Text(l10n.testAlertConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.send),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final sent = await BackgroundServices.sendSosAlert(l10n.smsTest);
    Fluttertoast.showToast(
      msg: sent == 0 ? l10n.noContactsFound : l10n.testAlertSent(sent),
    );
  }

  String _themeLabel(BuildContext context, ThemeMode mode) => switch (mode) {
    ThemeMode.system => context.l10n.themeSystem,
    ThemeMode.light => context.l10n.themeLight,
    ThemeMode.dark => context.l10n.themeDark,
  };

  Future<void> _selectTheme(BuildContext context, ThemeMode current) async {
    final mode = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l10n.appearance),
        children: [
          RadioGroup<ThemeMode>(
            groupValue: current,
            onChanged: (m) => Navigator.pop(context, m),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final m in ThemeMode.values)
                  RadioListTile<ThemeMode>(
                    value: m,
                    title: Text(_themeLabel(context, m)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (mode != null) await setThemeMode(mode);
  }

  Future<void> checkService() async {
    final folder = await AudioBackgroundRecord.getInstance()
        .getRecordingDestination();
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      switchAudioRecord = prefs.getBool("bgRecord") ?? false;
      switchValue = prefs.getBool("smsSend") ?? false;
      recordFolder = folder;
    });
  }

  Future<void> controllSafeShake(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("smsSend", val);
    await BackgroundServices.setSafeShake(val);
  }

  Future<void> controlAudioBgRecord(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("bgRecord", val);
    await BackgroundServices.setAudioRecording(val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              context.l10n.settings,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
          ),
          FutureBuilder(
            future: checkPIN(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListTile(
                  onTap: () => _onPinTap(context, snapshot.data!),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.password,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    snapshot.data == -1111
                        ? context.l10n.createPin
                        : context.l10n.changePin,
                  ),
                  subtitle: Text(context.l10n.pinRequired),
                  trailing: CircleAvatar(
                    radius: 7,
                    backgroundColor: snapshot.data == -1111
                        ? Latte.red
                        : Colors.transparent,
                    child: Center(
                      child: Card(
                        color: snapshot.data == -1111
                            ? Latte.peach
                            : Colors.transparent,
                        shape: CircleBorder(),
                        child: SizedBox(height: 5, width: 5),
                      ),
                    ),
                  ),
                );
              } else {
                return SizedBox();
              }
            },
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  context.l10n.alertsSection,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          ListTile(
            onTap: () {
              showLanguagePicker(context);
            },
            leading: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.translate,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
            title: Text(context.l10n.language),
            subtitle: Text(context.l10n.changeLanguage),
          ),
          FutureBuilder<bool>(
            future: DiscreetMode.isEnabled(),
            builder: (context, snap) => SwitchListTile(
              value: snap.data ?? false,
              onChanged: (on) => _setDiscreet(context, on),
              secondary: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.visibility_off_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
              title: Text(context.l10n.discreetMode),
              subtitle: Text(context.l10n.discreetModeSubtitle),
            ),
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: appThemeMode,
            builder: (context, mode, _) => ListTile(
              onTap: () => _selectTheme(context, mode),
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.dark_mode_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
              title: Text(context.l10n.appearance),
              subtitle: Text(_themeLabel(context, mode)),
            ),
          ),
          Divider(indent: 40, endIndent: 40),
          SwitchListTile(
            onChanged: (val) {
              setState(() {
                switchValue = val;
                controllSafeShake(val);
              });
            },
            value: switchValue,
            secondary: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.vibration,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
            title: Text(context.l10n.safeShake),
            subtitle: Text(context.l10n.safeShakeSubtitle),
          ),
          ListTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MedicalIdScreen()),
            ),
            leading: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.medical_information_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
            title: Text(context.l10n.medicalId),
            subtitle: Text(context.l10n.medicalIdSubtitle),
          ),
          ListTile(
            onTap: () => _sendTestAlert(context),
            leading: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.send_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
            title: Text(context.l10n.testAlert),
            subtitle: Text(context.l10n.testAlertSubtitle),
          ),
          FutureBuilder<bool>(
            future: FallDetection.isEnabled(),
            builder: (context, snap) => SwitchListTile(
              value: snap.data ?? false,
              onChanged: (on) async {
                await FallDetection.setEnabled(on);
                if (mounted) setState(() {});
              },
              secondary: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.personal_injury_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
              title: Text(context.l10n.fallDetection),
              subtitle: Text(context.l10n.fallDetectionSubtitle),
            ),
          ),
          FutureBuilder<bool>(
            future: LowBatteryAlert.isEnabled(),
            builder: (context, snap) => SwitchListTile(
              value: snap.data ?? false,
              onChanged: (on) async {
                await LowBatteryAlert.setEnabled(on);
                if (mounted) setState(() {});
              },
              secondary: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.battery_alert_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
              title: Text(context.l10n.lowBattery),
              subtitle: Text(context.l10n.lowBatterySubtitle),
            ),
          ),
          FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snap) {
              final seconds =
                  snap.data?.getInt(countdownSecondsKey) ??
                  defaultCountdownSeconds;
              return ListTile(
                onTap: () => _selectCountdown(context, seconds),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.timer_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
                title: Text(context.l10n.countdownSetting),
                subtitle: Text(
                  seconds == 0
                      ? context.l10n.off
                      : context.l10n.seconds(seconds),
                ),
              );
            },
          ),
          Divider(indent: 40, endIndent: 40),
          SwitchListTile(
            onChanged: (val) {
              setState(() {
                switchAudioRecord = val;
                controlAudioBgRecord(val);
              });
            },
            value: switchAudioRecord,
            secondary: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.mic_none,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
            title: Text(context.l10n.audioRecord),
            subtitle: Text(context.l10n.audioRecordSubtitle),
          ),
          Divider(indent: 40, endIndent: 40),
          ListTile(
            onTap: () => _selectRecordDuration(context),
            trailing: Icon(Icons.keyboard_arrow_right),
            leading: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.hourglass_bottom,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
            title: Text(context.l10n.audioRecordLength),
            subtitle: Text(context.l10n.audioRecordLengthSubtitle),
          ),
          Divider(indent: 40, endIndent: 40),
          ListTile(
            onTap: () => _selectRecordFolder(context),
            trailing: Icon(Icons.keyboard_arrow_right),
            leading: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.folder_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
            title: Text(context.l10n.audioRecordFolder),
            subtitle: Text(
              recordFolder ?? context.l10n.audioRecordFolderPrivate,
            ),
          ),
          Divider(indent: 40, endIndent: 40),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              context.l10n.safeShakeExplain,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  context.l10n.appSection,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUs()),
              );
            },
            title: Text(context.l10n.about),
            leading: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
          ),
          for (final (document, label, icon) in [
            (
              'privacy_policy',
              context.l10n.privacyLink,
              Icons.privacy_tip_outlined,
            ),
            ('terms', context.l10n.termsLink, Icons.description_outlined),
          ])
            ListTile(
              onTap: () => showDialog(
                context: context,
                builder: (_) => PolicyDialog(document: document),
              ),
              title: Text(label),
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
