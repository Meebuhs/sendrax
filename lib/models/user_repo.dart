import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendrax/util/constants.dart';
import 'package:sendrax/util/serialization_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_repo.dart';
import 'user.dart';

class UserRepo {
  static UserRepo _instance;

  final Firestore _firestore;

  UserRepo._internal(this._firestore);

  factory UserRepo.getInstance() {
    if (_instance == null) {
      _instance = UserRepo._internal(FirebaseRepo.getInstance().firestore);
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

  Stream<List<String>> getUserCategories(User user) {
    return _firestore
        .document("${FirestorePaths.USERS_COLLECTION}/${user.uid}/")
        .snapshots()
        .map((data) => Deserializer.deserializeCategories(data));
  }
}
