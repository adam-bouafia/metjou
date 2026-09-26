import 'package:flutter/material.dart';
import 'package:metjou/core/localization/app_locale.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metjou/features/contacts/presentation/my_contacts.dart';
import 'package:metjou/features/contacts/data/sos_contacts.dart';
import 'package:metjou/features/get_home_safe/data/get_home_safe_service.dart';

class SafeHome extends StatefulWidget {
  const SafeHome({super.key});

  @override
  State<SafeHome> createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> {
  bool getHomeSafeActivated = false;
  List<SosContact> numbers = [];

  @override
  void initState() {
    super.initState();

    checkGetHomeActivated();
  }

  Future<void> checkGetHomeActivated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      getHomeSafeActivated = prefs.getBool("getHomeSafe") ?? false;
    });
  }

  Future<void> changeStateOfHomeSafe(bool value) async {
    Fluttertoast.showToast(
      msg: value ? context.l10n.getHomeSafeOn : context.l10n.getHomeSafeOff,
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      getHomeSafeActivated = value;
      prefs.setBool("getHomeSafe", value);
    });
  }

  Future<void> showModelSafeHome(bool processRunning) async {
    int selectedContact = -1;
    bool getHomeActivated = processRunning;
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height / 1.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Expanded(child: Divider(indent: 20, endIndent: 20)),
                        Text(context.l10n.getHomeSafe),
                        Expanded(child: Divider(indent: 20, endIndent: 20)),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFFF5F4F6),
                    ),
                    child: SwitchListTile(
                      secondary: Lottie.asset("assets/routes.json"),
                      value: getHomeActivated,
                      onChanged: (val) async {
                        if (val && selectedContact == -1) {
                          Fluttertoast.showToast(
                            msg: context.l10n.selectContactFirst,
                          );
                          return;
                        }
                        setModalState(() {
                          getHomeActivated = val;
                        });
                        if (getHomeActivated) {
                          changeStateOfHomeSafe(true);
                          await GetHomeSafeService.start(
                            numbers[selectedContact].phone,
                            const RepeatEvery(Duration(minutes: 15)),
                          );
                        } else {
                          changeStateOfHomeSafe(false);
                          await GetHomeSafeService.stop();
                        }
                      },
                      subtitle: Text(context.l10n.getHomeSafeInterval),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder(
                      future: getSOSNumbers(),
                      builder:
                          (context, AsyncSnapshot<List<SosContact>> snapshot) {
                            final contacts = snapshot.data ?? [];
                            if (contacts.isNotEmpty) {
                              return ListView.separated(
                                itemCount: contacts.length,
                                separatorBuilder: (context, index) {
                                  return Divider(indent: 20, endIndent: 20);
                                },
                                itemBuilder: (context, index) {
                                  final contactData = contacts[index];
                                  return ListTile(
                                    onTap: () {
                                      setModalState(() {
                                        selectedContact = index;
                                      });
                                    },
                                    leading: CircleAvatar(
                                      backgroundImage: AssetImage(
                                        "assets/user.webp",
                                      ),
                                    ),
                                    title: Text(contactData.name),
                                    subtitle: Text(contactData.phone),
                                    trailing: selectedContact == index
                                        ? Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          )
                                        : null,
                                  );
                                },
                              );
                            } else {
                              return ListTile(
                                onTap: () async {
                                  await pickSosContact(context);
                                  setModalState(() {});
                                },
                                title: Text(context.l10n.noContacts),
                                subtitle: Text(context.l10n.addContactHint),
                                trailing: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.grey,
                                ),
                              );
                            }
                          },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<SosContact>> getSOSNumbers() async {
    numbers = await loadSosContacts();
    return numbers;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: InkWell(
        onTap: () {
          showModelSafeHome(getHomeSafeActivated);
        },
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: 180,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ListTile(
                        title: Text(context.l10n.getHomeSafe),
                        subtitle: Text(context.l10n.getHomeSafeSubtitle),
                      ),
                      Visibility(
                        visible: getHomeSafeActivated,
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            children: [
                              SpinKitDoubleBounce(color: Colors.red, size: 15),
                              SizedBox(width: 15),
                              Text(
                                context.l10n.getHomeSafeActive,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset("assets/route.webp", height: 140),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
