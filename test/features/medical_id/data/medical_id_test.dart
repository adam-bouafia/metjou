import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/features/medical_id/data/medical_id.dart';
import 'package:metjou/l10n/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('empty until something is filled in', () {
    expect(const MedicalId().isEmpty, isTrue);
    expect(const MedicalId(allergies: 'Penicillin').isEmpty, isFalse);
  });

  test('lines list only filled-in fields, with labels', () {
    const id = MedicalId(
      bloodType: 'O-',
      allergies: ' Penicillin ',
      emergencyName: 'Sara',
      emergencyPhone: '0612345678',
    );
    expect(id.lines(l10n), [
      'Blood type: O-',
      'Allergies: Penicillin',
      'Emergency contact: Sara 0612345678',
    ]);
  });

  test('survives a JSON round trip', () {
    const id = MedicalId(
      name: 'Adam',
      medications: 'None',
      showOnLockScreen: true,
    );
    final back = MedicalId.fromJson(id.toJson());
    expect(back.name, 'Adam');
    expect(back.medications, 'None');
    expect(back.showOnLockScreen, isTrue);
  });
}
