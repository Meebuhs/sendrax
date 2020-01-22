import 'package:flutter/material.dart';

import 'climb/climb_view.dart';
import 'create_climb/create_climb_view.dart';
import 'create_location/create_location_view.dart';
import 'location/location_view.dart';
import 'login/login_view.dart';
import 'main/main_view.dart';
import 'models/climb.dart';
import 'models/location.dart';

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

  static void navigateToLocation(BuildContext context, SelectedLocation location,
      {bool addToBackStack: false}) {
    if (addToBackStack) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LocationScreen(location: location)));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LocationScreen(location: location)));
    }
  }

  static void navigateToCreateLocation(BuildContext context, Location location, bool isEdit,
      {bool addToBackStack: false}) {
    if (addToBackStack) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CreateLocationScreen(location: location, isEdit: isEdit)));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CreateLocationScreen(location: location, isEdit: isEdit)));
    }
  }

  static void navigateToCreateClimb(
      BuildContext context, Climb climb, List<String> sections, bool isEdit,
      {bool addToBackStack: false}) {
    if (addToBackStack) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CreateClimbScreen(climb: climb, availableSections: sections, isEdit: isEdit)));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CreateClimbScreen(climb: climb, availableSections: sections, isEdit: isEdit)));
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

  static void navigateBackOne(BuildContext context) {
    Navigator.pop(context);
  }
}
