import 'dart:async';

import 'package:sendrax/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user.dart';

class UserRepo {
  static UserRepo _instance;

  UserRepo._internal();

  factory UserRepo.getInstance() {
    if (_instance == null) {
      _instance = UserRepo._internal();
    }
    return _instance;
  }

  Future<User> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(StorageKeys.USER_ID_KEY);
    String displayName = prefs.getString(StorageKeys.USER_DISPLAY_NAME_KEY);
    if (userId != null) {
      return User(userId, displayName);
    }
    return null;
  }

  void setCurrentUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs
        .setString(StorageKeys.USER_ID_KEY, user.uid)
        .then((value) => prefs.setString(StorageKeys.USER_DISPLAY_NAME_KEY, user.displayName));
  }

  void clearCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
