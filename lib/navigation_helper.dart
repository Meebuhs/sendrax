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

  static void navigateToLocation(
      BuildContext context, SelectedLocation location, List<String> categories,
      {bool addToBackStack: false}) {
    if (addToBackStack) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LocationScreen(
                    location: location,
                    categories: categories,
                  )));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LocationScreen(
                    location: location,
                    categories: categories,
                  )));
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
      BuildContext context,
      Climb climb,
      SelectedLocation selectedLocation,
      List<String> sections,
      List<String> categories,
      bool isEdit,
      {bool addToBackStack: false}) {
    if (addToBackStack) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CreateClimbScreen(
                  climb: climb,
                  selectedLocation: selectedLocation,
                  availableSections: sections,
                  categories: categories,
                  isEdit: isEdit)));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CreateClimbScreen(
                  climb: climb,
                  selectedLocation: selectedLocation,
                  availableSections: sections,
                  categories: categories,
                  isEdit: isEdit)));
    }
  }

  static void navigateToClimb(BuildContext context, Climb climb, SelectedLocation selectedLocation,
      List<String> sections, List<String> categories,
      {bool addToBackStack: false}) {
    if (addToBackStack) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ClimbScreen(
                  climb: climb,
                  selectedLocation: selectedLocation,
                  sections: sections,
                  categories: categories)));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ClimbScreen(
                  climb: climb,
                  selectedLocation: selectedLocation,
                  sections: sections,
                  categories: categories)));
    }
  }

  static void navigateBackOne(BuildContext context) {
    Navigator.pop(context);
  }

  static void resetToMain(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainScreen()), (Route<dynamic> route) => false);
  }

  static void resetToLocation(
      BuildContext context, SelectedLocation location, List<String> categories) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => LocationScreen(
                  location: location,
                  categories: categories,
                )),
        (Route<dynamic> route) => false);
  }
}
