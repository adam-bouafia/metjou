import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/features/contacts/data/sos_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('normalizePhoneNumber', () {
    for (final (input, expected) in [
      ('06 1234 5678', '0612345678'),
      ('+31 (0)6-12345678', '+31612345678'),
      ('0031 6 12345678', '+31612345678'),
      ('+216 20 123 456', '+21620123456'),
    ]) {
      test('turns "$input" into "$expected"', () {
        expect(normalizePhoneNumber(input), expected);
      });
    }
  });

  group('addSosContact', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('stores contacts that load back unchanged', () async {
      await addSosContact(const SosContact(name: 'Sara', phone: '0612345678'));

      final contacts = await loadSosContacts();
      expect(contacts.single.name, 'Sara');
      expect(contacts.single.phone, '0612345678');
    });

    test('rejects a number that is already saved', () async {
      await addSosContact(const SosContact(name: 'Sara', phone: '0612345678'));

      final added = await addSosContact(
        const SosContact(name: 'Sara 2', phone: '0612345678'),
      );

      expect(added, isFalse);
      expect(await loadSosContacts(), hasLength(1));
    });

    test('rejects contacts beyond the maximum', () async {
      for (var i = 0; i < maxSosContacts; i++) {
        expect(
          await addSosContact(SosContact(name: 'c$i', phone: '06$i')),
          isTrue,
        );
      }

      expect(
        await addSosContact(const SosContact(name: 'extra', phone: '0699')),
        isFalse,
      );
      expect(await loadSosContacts(), hasLength(maxSosContacts));
    });
  });
}
