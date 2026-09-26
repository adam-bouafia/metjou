import 'package:flutter/material.dart';

/// Lets code outside the widget tree (launch actions, notifications) open
/// screens.
final appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> pushScreen(Widget screen) async {
  await appNavigatorKey.currentState?.push(
    MaterialPageRoute(builder: (_) => screen),
  );
}
