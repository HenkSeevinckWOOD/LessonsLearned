import 'package:flutter/material.dart';
import '../../LocalStorage/localstorage.dart';
import '../../Pages/signin.dart';
import '../../Widgets/widgets.dart';

Future<void> userKeyExpired({
required BuildContext context
}) async {
// Remove credentials and route to Signin
  LocalStorageService.removeUserID();
  LocalStorageService.removeUserKey();
  snackbar(
    context: context,
    header: 'Userkey expired, please sign in to proceed',
  );
  await Future.delayed(Duration(seconds: 2));
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const Signin()),
    (route) => false,
  );
}