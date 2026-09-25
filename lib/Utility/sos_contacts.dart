import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Maximum number of people that receive an SOS alert.
const int maxSosContacts = 3;

const String _prefsKey = "sos_contacts";

class SosContact {
  const SosContact({required this.name, required this.phone});

  final String name;
  final String phone;

  Map<String, String> toJson() => {"name": name, "phone": phone};

  factory SosContact.fromJson(Map<String, dynamic> json) =>
      SosContact(name: json["name"] as String, phone: json["phone"] as String);
}

/// Strips formatting from a phone number and turns a 00 prefix into +.
/// Local numbers (e.g. 06...) are left as they are; the SIM's network
/// routes them.
String normalizePhoneNumber(String raw) {
  var phone = raw.replaceAll(RegExp(r"[^\d+]"), "");
  if (phone.startsWith("00")) phone = "+${phone.substring(2)}";
  return phone;
}

Future<List<SosContact>> loadSosContacts() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  return (prefs.getStringList(_prefsKey) ?? [])
      .map((e) => SosContact.fromJson(jsonDecode(e) as Map<String, dynamic>))
      .toList();
}

Future<void> saveSosContacts(List<SosContact> contacts) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
      _prefsKey, contacts.map((c) => jsonEncode(c.toJson())).toList());
}

/// Adds a contact unless the number is already saved or the list is full.
/// Returns false when nothing was added.
Future<bool> addSosContact(SosContact contact) async {
  final contacts = await loadSosContacts();
  if (contacts.length >= maxSosContacts ||
      contacts.any((c) => c.phone == contact.phone)) {
    return false;
  }
  await saveSosContacts([...contacts, contact]);
  return true;
}
