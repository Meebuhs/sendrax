import 'package:flutter/material.dart';

import 'climb/climb_view.dart';
import 'location/location_view.dart';
import 'login/login_view.dart';
import 'main/main_view.dart';

class NavigationHelper {
  static void navigateToLogin(BuildContext context, {bool addToBackStack: false}) {
    if (addToBackStack) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  static void navigateToMain(BuildContext context, {bool addToBackStack: false}) {
    if (addToBackStack) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
    }
  }

  static void navigateToLocation(BuildContext context, String displayName, String locationId,
      {bool addToBackStack: false}) {
    if (addToBackStack) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LocationScreen(displayName: displayName, locationId: locationId)));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LocationScreen(displayName: displayName, locationId: locationId)));
    }
  }

  static void navigateToClimb(BuildContext context, String displayName, String climbId,
      {bool addToBackStack: false}) {
    if (addToBackStack) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ClimbScreen(displayName: displayName, climbId: climbId)));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ClimbScreen(displayName: displayName, climbId: climbId)));
    }
  }
}
