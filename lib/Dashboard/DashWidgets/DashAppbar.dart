import 'package:flutter/material.dart';
import 'package:metjou/Dashboard/Settings/SettingsScreen.dart';
import 'package:metjou/Utility/constants.dart';

class DashAppbar extends StatelessWidget {
  DashAppbar({super.key, required this.getRandomInt, required this.quoteIndex});

  final Function getRandomInt;
  final int quoteIndex;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        sweetSayings[quoteIndex][0],
        style: TextStyle(fontFamily: 'metaplusmedium',
          color: Colors.grey[600],
        ),
      ),
      subtitle: GestureDetector(
        onTap: () {
          getRandomInt(true);
        },
        child: Text(
          sweetSayings[quoteIndex][1],
          style: TextStyle(fontFamily: 'metaplusmedium',
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width * 0.06),
        ),
      ),
      trailing: Card(
        elevation: 4,
        shape: CircleBorder(),
        child: InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SettingsScreen()));
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.asset(
              "assets/settings.webp",
              height: 24,
            ),
          ),
        ),
      ),
    );
  }
}
