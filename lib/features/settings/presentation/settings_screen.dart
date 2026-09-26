import 'package:audio_background_record/audio_background_record.dart';
import 'package:flutter/material.dart';
import 'package:metjou/core/theme/app_theme.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metjou/features/settings/presentation/about.dart';
import 'package:metjou/features/settings/presentation/change_pin.dart';
import 'package:metjou/core/services/background_services.dart';
import 'package:metjou/features/legal/presentation/policy_dialog.dart';
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
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900),
            ),
          ),
          FutureBuilder(
            future: checkPIN(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChangePinScreen(pin: snapshot.data!),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Center(child: Image.asset("assets/pin.webp")),
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
              child: Center(
                child: Image.asset("assets/language.webp", height: 24),
              ),
            ),
            title: Text(context.l10n.language),
            subtitle: Text(context.l10n.changeLanguage),
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
              child: Center(
                child: Image.asset("assets/shake.webp", height: 24),
              ),
            ),
            title: Text(context.l10n.safeShake),
            subtitle: Text(context.l10n.safeShakeSubtitle),
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
              child: Center(
                child: Image.asset("assets/record.webp", height: 24),
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
              child: Center(
                child: Image.asset("assets/timer.webp", height: 24),
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
              child: Center(child: Image.asset("assets/info.webp", height: 24)),
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
