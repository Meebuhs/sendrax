import 'package:flutter/material.dart';
import 'package:sendrax/view_only_climb/view_only_climb_view.dart';

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
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LoginScreen(), settings: RouteSettings(name: '/login')));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LoginScreen(), settings: RouteSettings(name: '/login')));
    }
  }

  static void navigateToMain(BuildContext context, {bool addToBackStack: false}) {
    if (addToBackStack) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(), settings: RouteSettings(name: '/')));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(), settings: RouteSettings(name: '/')));
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
                  ),
              settings: RouteSettings(name: '/location')));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LocationScreen(
                    location: location,
                    categories: categories,
                  ),
              settings: RouteSettings(name: '/location')));
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
      List<String> grades,
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
                  sections: sections,
                  grades: grades,
                  categories: categories,
                  isEdit: isEdit)));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CreateClimbScreen(
                  climb: climb,
                  selectedLocation: selectedLocation,
                  sections: sections,
                  grades: grades,
                  categories: categories,
                  isEdit: isEdit)));
    }
  }

  static void navigateToClimb(BuildContext context, Climb climb, SelectedLocation selectedLocation,
      List<String> sections, List<String> grades, List<String> categories,
      {bool addToBackStack: false}) {
    if (addToBackStack) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ClimbScreen(
                  climb: climb,
                  selectedLocation: selectedLocation,
                  sections: sections,
                  grades: grades,
                  categories: categories),
              settings: RouteSettings(name: '/location/climb')));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ClimbScreen(
                  climb: climb,
                  selectedLocation: selectedLocation,
                  sections: sections,
                  grades: grades,
                  categories: categories),
              settings: RouteSettings(name: '/location/climb')));
    }
  }

  static void navigateToViewOnlyClimb(BuildContext context, String climbId, String climbName,
      {bool addToBackStack: false}) {
    if (addToBackStack) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ViewOnlyClimbScreen(climbId: climbId, climbName: climbName)));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ViewOnlyClimbScreen(climbId: climbId, climbName: climbName)));
    }
  }

  static void navigateBackOne(BuildContext context) {
    Navigator.pop(context);
  }

  static void navigateBackTwo(BuildContext context) {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  static void resetToMain(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainScreen()), ModalRoute.withName('/'));
  }

  static void resetToLocation(
      BuildContext context, SelectedLocation location, List<String> categories) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => LocationScreen(
                  location: location,
                  categories: categories,
                )),
        ModalRoute.withName('/'));
  }
}
