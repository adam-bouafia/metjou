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
