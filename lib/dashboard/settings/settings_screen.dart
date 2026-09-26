import 'package:audio_background_record/audio_background_record.dart';
import 'package:flutter/material.dart';
import 'package:metjou/utility/app_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metjou/dashboard/settings/about.dart';
import 'package:metjou/dashboard/settings/change_pin.dart';
import 'package:metjou/utility/background_services.dart';
import 'package:metjou/utility/language_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool switchValue = false;
  bool switchAudioRecord = false;

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
      await AudioBackgroundRecord.getInstance()
          .configure(maxDurationInMillis: selected.inMilliseconds);
    }
  }

  Future<int> checkPIN() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int pin = (prefs.getInt('pin') ?? -1111);
    return pin;
  }

  Future<void> checkService() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      switchAudioRecord = prefs.getBool("bgRecord") ?? false;
      switchValue = prefs.getBool("smsSend") ?? false;
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
      backgroundColor: Color(0xFFFAFCFE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              context.l10n.settings,
              style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w900),
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
                      backgroundColor: Colors.grey[200],
                      child: Center(
                        child: Image.asset("assets/pin.webp"),
                      ),
                    ),
                    title: Text(
                        snapshot.data == -1111 ? context.l10n.createPin : context.l10n.changePin),
                    subtitle: Text(context.l10n.pinRequired),
                    trailing: CircleAvatar(
                      radius: 7,
                      backgroundColor:
                          snapshot.data == -1111 ? Colors.red : Colors.white,
                      child: Center(
                        child: Card(
                            color: snapshot.data == -1111
                                ? Colors.orange
                                : Colors.white,
                            shape: CircleBorder(),
                            child: SizedBox(
                              height: 5,
                              width: 5,
                            )),
                      ),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              }),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  context.l10n.alertsSection,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Expanded(child: Divider())
            ],
          ),
          ListTile(
            onTap: () {
              showLanguagePicker(context);
            },
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Center(
                  child: Image.asset(
                "assets/language.webp",
                height: 24,
              )),
            ),
            title: Text(context.l10n.language),
            subtitle: Text(context.l10n.changeLanguage),
          ),
          Divider(
            indent: 40,
            endIndent: 40,
          ),
          Divider(
            indent: 40,
            endIndent: 40,
          ),
          SwitchListTile(
            onChanged: (val) {
              setState(() {
                switchValue = val;
                controllSafeShake(val);
              });
            },
            value: switchValue,
            secondary: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Center(
                  child: Image.asset(
                "assets/shake.webp",
                height: 24,
              )),
            ),
            title: Text(context.l10n.safeShake),
            subtitle: Text(context.l10n.safeShakeSubtitle),
          ),
          Divider(
            indent: 40,
            endIndent: 40,
          ),
          SwitchListTile(
            onChanged: (val) {
              setState(() {
                switchAudioRecord = val;
                controlAudioBgRecord(val);
              });
            },
            value: switchAudioRecord,
            secondary: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Center(
                  child: Image.asset(
                "assets/record.webp",
                height: 24,
              )),
            ),
            title: Text(context.l10n.audioRecord),
            //TODO Translation
            subtitle: Text(context.l10n.audioRecordSubtitle),
          ),
          Divider(
            indent: 40,
            endIndent: 40,
          ),
          ListTile(
            trailing: IconButton(
              icon: Icon(Icons.keyboard_arrow_right),
              onPressed: () => _selectRecordDuration(context),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Center(
                child: Image.asset("assets/timer.webp", height: 24),
              ),
            ),
            title: Text(context.l10n.audioRecordLength),
            subtitle: Text(context.l10n.audioRecordLengthSubtitle),
          ),
          Divider(
            indent: 40,
            endIndent: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              context.l10n.safeShakeExplain,
              style:
                  TextStyle(color: Colors.grey),
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
              Expanded(child: Divider())
            ],
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AboutUs()));
            },
            title: Text(context.l10n.about),
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Center(
                  child: Image.asset(
                "assets/info.webp",
                height: 24,
              )),
            ),
          ),
        ],
      ),
    );
  }
}
