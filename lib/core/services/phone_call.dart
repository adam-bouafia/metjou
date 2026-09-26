import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Calls straight away when the phone permission is granted, otherwise
/// opens the dialer with the number filled in. A call must never fail
/// because of a missing permission.
Future<void> callNumber(String number) async {
  final digits = number.replaceAll(RegExp(r"[^\d+]"), "");
  if (await Permission.phone.isGranted &&
      (await FlutterPhoneDirectCaller.callNumber(digits) ?? false)) {
    return;
  }
  await launchUrl(Uri(scheme: 'tel', path: digits));
}
