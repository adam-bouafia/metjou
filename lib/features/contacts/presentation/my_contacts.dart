import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metjou/core/widgets/glass.dart';
import 'package:metjou/core/widgets/pin_guard.dart';
import 'package:metjou/features/contacts/data/sos_contacts.dart';
import 'package:metjou/features/home/presentation/widgets/glass_dock.dart';

/// Opens the system contact picker and saves the chosen number as an SOS
/// contact. Needs no contacts permission. Returns true if one was added.
/// Adds an SOS contact: pick one from the phone's contacts or type a
/// number. Returns true if one was added.
Future<bool> addSosContactFlow(BuildContext context) async {
  final l10n = context.l10n;
  final typed = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.contacts_outlined),
            title: Text(l10n.addFromContacts),
            onTap: () => Navigator.pop(context, false),
          ),
          ListTile(
            leading: const Icon(Icons.dialpad),
            title: Text(l10n.addByNumber),
            onTap: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ),
  );
  if (typed == null || !context.mounted) return false;
  return typed ? typeSosContact(context) : pickSosContact(context);
}

/// Form to type a name and number for an SOS contact.
Future<bool> typeSosContact(BuildContext context) async {
  final l10n = context.l10n;
  final contact = await showDialog<SosContact>(
    context: context,
    builder: (_) => const _TypeContactDialog(),
  );
  if (contact == null) return false;
  final added = await addSosContact(contact);
  Fluttertoast.showToast(
    msg: added ? l10n.contactSaved : l10n.contactNotAdded(maxSosContacts),
  );
  return added;
}

class _TypeContactDialog extends StatefulWidget {
  const _TypeContactDialog();

  @override
  State<_TypeContactDialog> createState() => _TypeContactDialogState();
}

class _TypeContactDialogState extends State<_TypeContactDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final name = _name.text.trim();
    Navigator.pop(
      context,
      SosContact(
        name: name.isEmpty ? context.l10n.noName : name,
        phone: normalizePhoneNumber(_phone.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.addContact),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.contactName,
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              autofocus: true,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              decoration: InputDecoration(
                labelText: l10n.contactPhone,
                hintText: "06 12345678",
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: (v) =>
                  isValidPhoneNumber(v ?? "") ? null : l10n.invalidPhone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}

Future<bool> pickSosContact(BuildContext context) async {
  final l10n = context.l10n;
  final picked = await FlutterNativeContactPicker().selectPhoneNumber();
  final number =
      picked?.selectedPhoneNumber ?? picked?.phoneNumbers?.firstOrNull;
  if (picked == null || number == null || number.isEmpty) return false;

  final added = await addSosContact(
    SosContact(
      name: picked.fullName ?? l10n.noName,
      phone: normalizePhoneNumber(number),
    ),
  );
  Fluttertoast.showToast(
    msg: added ? l10n.contactSaved : l10n.contactNotAdded(maxSosContacts),
  );
  return added;
}

class MyContactsScreen extends StatefulWidget {
  const MyContactsScreen({super.key});

  @override
  State<MyContactsScreen> createState() => _MyContactsScreenState();
}

class _MyContactsScreenState extends State<MyContactsScreen> {
  Future<void> _remove(List<SosContact> contacts, int index) async {
    if (!await confirmPin(context) || !mounted) return;
    final l10n = context.l10n;
    final removed = contacts.removeAt(index);
    await saveSosContacts(contacts);
    Fluttertoast.showToast(msg: l10n.contactRemoved(removed.name));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The dashboard's glass background shows through.
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          context.l10n.sosContacts,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Image.asset("assets/phone_red.webp"),
          onPressed: () {},
        ),
      ),
      body: FutureBuilder(
        future: loadSosContacts(),
        builder: (context, AsyncSnapshot<List<SosContact>> snap) {
          final contacts = snap.data ?? [];
          if (contacts.isEmpty) {
            return Center(child: Text(context.l10n.noContacts));
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(child: Divider(indent: 20, endIndent: 20)),
                    Text(context.l10n.swipeToDelete),
                    Expanded(child: Divider(indent: 20, endIndent: 20)),
                  ],
                ),
              ),
              Text(context.l10n.contactCount(contacts.length, maxSosContacts)),
              Expanded(
                child: ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return Slidable(
                      key: ValueKey(contact.phone),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.25,
                        children: [
                          SlidableAction(
                            onPressed: (_) => _remove(contacts, index),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        child: GlassPanel(
                          radius: 16,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              backgroundImage: AssetImage("assets/user.webp"),
                            ),
                            title: Text(contact.name),
                            subtitle: Text(contact.phone),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: glassDockClearance),
            ],
          );
        },
      ),
    );
  }
}
