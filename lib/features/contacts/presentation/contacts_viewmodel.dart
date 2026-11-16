import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metjou/features/contacts/data/sos_contacts.dart';

/// Holds the saved SOS contacts, loaded once instead of on every rebuild
/// (a plain `FutureBuilder(future: loadSosContacts())` restarts the load
/// every time its parent rebuilds).
class ContactsViewModel extends AsyncNotifier<List<SosContact>> {
  @override
  Future<List<SosContact>> build() => loadSosContacts();

  Future<void> remove(SosContact contact) async {
    final current = state.value ?? await loadSosContacts();
    final updated = [...current]..removeWhere((c) => c.phone == contact.phone);
    await saveSosContacts(updated);
    state = AsyncData(updated);
  }

  Future<void> reload() async {
    state = AsyncData(await loadSosContacts());
  }
}

final contactsViewModelProvider =
    AsyncNotifierProvider<ContactsViewModel, List<SosContact>>(
      ContactsViewModel.new,
    );
