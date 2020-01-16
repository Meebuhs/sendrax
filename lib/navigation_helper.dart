import 'package:flutter/material.dart';

import 'login/login_view.dart';
import 'main/main_view.dart';

class NavigationHelper {
  static void navigateToLogin(BuildContext context,
      {bool addToBackStack: false}) {
    if (addToBackStack) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  static void navigateToMain(BuildContext context,
      {bool addToBackStack: false}) {
    if (addToBackStack) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainScreen()));
    }
  }
}
