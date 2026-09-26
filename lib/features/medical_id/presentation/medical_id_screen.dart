import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/features/medical_id/data/medical_id.dart';

/// Fill in health details for first responders.
class MedicalIdScreen extends StatefulWidget {
  const MedicalIdScreen({super.key});

  @override
  State<MedicalIdScreen> createState() => _MedicalIdScreenState();
}

class _MedicalIdScreenState extends State<MedicalIdScreen> {
  final _name = TextEditingController();
  final _birth = TextEditingController();
  final _allergies = TextEditingController();
  final _medications = TextEditingController();
  final _conditions = TextEditingController();
  final _emergencyName = TextEditingController();
  final _emergencyPhone = TextEditingController();
  final _notes = TextEditingController();
  String _blood = "";
  bool _lockScreen = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    MedicalId.load().then((m) {
      if (!mounted) return;
      _name.text = m.name;
      _birth.text = m.birthDate;
      _allergies.text = m.allergies;
      _medications.text = m.medications;
      _conditions.text = m.conditions;
      _emergencyName.text = m.emergencyName;
      _emergencyPhone.text = m.emergencyPhone;
      _notes.text = m.notes;
      setState(() {
        _blood = m.bloodType;
        _lockScreen = m.showOnLockScreen;
        _loaded = true;
      });
    });
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _birth,
      _allergies,
      _medications,
      _conditions,
      _emergencyName,
      _emergencyPhone,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final saved = context.l10n.medSaved;
    await MedicalId(
      name: _name.text,
      birthDate: _birth.text,
      bloodType: _blood,
      allergies: _allergies.text,
      medications: _medications.text,
      conditions: _conditions.text,
      emergencyName: _emergencyName.text,
      emergencyPhone: _emergencyPhone.text,
      notes: _notes.text,
      showOnLockScreen: _lockScreen,
    ).save();
    Fluttertoast.showToast(msg: saved);
    if (mounted) Navigator.pop(context);
  }

  Widget _field(
    TextEditingController c,
    String label, {
    TextInputType? type,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      keyboardType: type,
      minLines: 1,
      maxLines: lines,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medicalId),
        actions: [
          TextButton(onPressed: _loaded ? _save : null, child: Text(l10n.save)),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _field(_name, l10n.medName),
                _field(_birth, l10n.medBirth, type: TextInputType.datetime),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                    initialValue: _blood,
                    decoration: InputDecoration(
                      labelText: l10n.medBlood,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: "", child: Text(l10n.medUnknown)),
                      for (final b in bloodTypes)
                        DropdownMenuItem(value: b, child: Text(b)),
                    ],
                    onChanged: (v) => setState(() => _blood = v ?? ""),
                  ),
                ),
                _field(_allergies, l10n.medAllergies, lines: 3),
                _field(_medications, l10n.medMedications, lines: 3),
                _field(_conditions, l10n.medConditions, lines: 3),
                _field(_emergencyName, l10n.medEmergencyName),
                _field(
                  _emergencyPhone,
                  l10n.medEmergencyPhone,
                  type: TextInputType.phone,
                ),
                _field(_notes, l10n.medNotes, lines: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _lockScreen,
                  onChanged: (v) => setState(() => _lockScreen = v),
                  title: Text(l10n.medLockScreen),
                  subtitle: Text(l10n.medLockScreenSubtitle),
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _save, child: Text(l10n.save)),
              ],
            ),
    );
  }
}
