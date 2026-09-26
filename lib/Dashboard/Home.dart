import 'dart:math';
import 'package:get/get.dart';
import 'package:metjou/Utility/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:metjou/Dashboard/Articles/AllArticles.dart';
import 'package:metjou/Dashboard/DashWidgets/DashAppbar.dart';
import 'package:metjou/Dashboard/DashWidgets/Emergency.dart';
import 'package:metjou/Dashboard/DashWidgets/LiveSafe.dart';
import 'package:metjou/Dashboard/Articles/SafeCarousel.dart';
import 'package:metjou/Dashboard/DashWidgets/SafeHome.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int quoteIndex = 0;

  @override
  void initState() {
    super.initState();
    getRandomInt(false);
  }

  getRandomInt(fromClick) {
    Random rnd = Random();

    quoteIndex = rnd.nextInt(4);
    if (mounted && fromClick) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashAppbar(
          getRandomInt: getRandomInt,
          quoteIndex: quoteIndex,
        ),
        Expanded(
          child: Container(
            child: ListView(
              shrinkWrap: true,
              children: [
                SafeCarousel(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          context.l10n.emergency,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllArticles(),
                            ),
                          );
                        },
                        child: Text("vps".tr, style: TextStyle(color: Colors.blueAccent)),
                      ),
                    ],
                  ),
                ),
                Emergency(),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, bottom: 10, top: 10),
                  child: Text(
                    context.l10n.safePlaces,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                LiveSafe(),
                SafeHome(),
                SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
