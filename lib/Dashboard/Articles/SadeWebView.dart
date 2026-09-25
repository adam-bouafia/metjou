import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:metjou/Utility/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SafeWebView extends StatelessWidget {
  const SafeWebView({super.key, required this.url, required this.title, required this.index});

  final int index;
  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    
    return WebView(
      initialUrl: url,
      /*appBar: CupertinoNavigationBar(
        middle: Text(title),
        trailing: CircleAvatar(
          backgroundColor: Colors.grey[200],
          backgroundImage: NetworkImage(imageSliders[index]),
        ),
      ),*/
    );
  }
}
