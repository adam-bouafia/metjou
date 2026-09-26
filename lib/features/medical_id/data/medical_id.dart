import 'dart:convert';

import 'package:metjou/core/localization/app_locale.dart';
import 'package:metjou/core/services/background_services.dart';
import 'package:metjou/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = "medical_id";

const bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];

/// Health details for first responders, stored only on the phone.
class MedicalId {
  const MedicalId({
    this.name = "",
    this.birthDate = "",
    this.bloodType = "",
    this.allergies = "",
    this.medications = "",
    this.conditions = "",
    this.emergencyName = "",
    this.emergencyPhone = "",
    this.notes = "",
    this.showOnLockScreen = false,
  });

  final String name;
  final String birthDate;
  final String bloodType;
  final String allergies;
  final String medications;
  final String conditions;
  final String emergencyName;
  final String emergencyPhone;
  final String notes;
  final bool showOnLockScreen;

  bool get isEmpty => lines(null).isEmpty;

  Map<String, Object> toJson() => {
    "name": name,
    "birthDate": birthDate,
    "bloodType": bloodType,
    "allergies": allergies,
    "medications": medications,
    "conditions": conditions,
    "emergencyName": emergencyName,
    "emergencyPhone": emergencyPhone,
    "notes": notes,
    "showOnLockScreen": showOnLockScreen,
  };

  factory MedicalId.fromJson(Map<String, dynamic> j) => MedicalId(
    name: j["name"] as String? ?? "",
    birthDate: j["birthDate"] as String? ?? "",
    bloodType: j["bloodType"] as String? ?? "",
    allergies: j["allergies"] as String? ?? "",
    medications: j["medications"] as String? ?? "",
    conditions: j["conditions"] as String? ?? "",
    emergencyName: j["emergencyName"] as String? ?? "",
    emergencyPhone: j["emergencyPhone"] as String? ?? "",
    notes: j["notes"] as String? ?? "",
    showOnLockScreen: j["showOnLockScreen"] as bool? ?? false,
  );

  /// Filled-in fields as "Label: value" lines. Labels are left out when
  /// [l10n] is null (used to check whether anything is filled in).
  List<String> lines(AppLocalizations? l10n) {
    final emergency = [
      emergencyName,
      emergencyPhone,
    ].where((v) => v.isNotEmpty).join(" ");
    return [
          (l10n?.medName, name),
          (l10n?.medBirth, birthDate),
          (l10n?.medBlood, bloodType),
          (l10n?.medAllergies, allergies),
          (l10n?.medMedications, medications),
          (l10n?.medConditions, conditions),
          (l10n?.medEmergencyName, emergency),
          (l10n?.medNotes, notes),
        ]
        .where((e) => e.$2.trim().isNotEmpty)
        .map((e) => "${e.$1 ?? ''}: ${e.$2.trim()}")
        .toList();
  }

  static Future<MedicalId> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_prefsKey);
    return raw == null
        ? const MedicalId()
        : MedicalId.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save() async {
    await (await SharedPreferences.getInstance()).setString(
      _prefsKey,
      jsonEncode(toJson()),
    );
    await updateLockScreen();
  }

  /// Shows or removes the lock screen notification to match the settings.
  Future<void> updateLockScreen() async {
    if (!showOnLockScreen || isEmpty) {
      await BackgroundServices.cancelMedicalIdNotification();
      return;
    }
    final l10n = await backgroundLocalizations();
    await BackgroundServices.showMedicalIdNotification(
      title: l10n.medicalId,
      body: lines(l10n).join("\n"),
    );
  }
}
