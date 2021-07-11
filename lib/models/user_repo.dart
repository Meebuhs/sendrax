import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendrax/util/constants.dart';
import 'package:sendrax/util/serialization_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_repo.dart';
import 'user.dart';

class UserRepo {
  static UserRepo _instance;

  final FirebaseFirestore _firestore;

  UserRepo._internal(this._firestore);

  factory UserRepo.getInstance() {
    if (_instance == null) {
      _instance = UserRepo._internal(FirebaseRepo.getInstance().firestore);
    }
    return _instance;
  }

  Future<AppUser> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(StorageKeys.USER_ID_KEY);
    if (userId != null) {
      return AppUser(userId);
    }
    return null;
  }

  void setCurrentUser(AppUser user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.USER_ID_KEY, user.uid);
  }

  void clearCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Stream<List<String>> getUserCategories(AppUser user) {
    return _firestore
        .doc("${FirestorePaths.USERS_COLLECTION}/${user.uid}/")
        .snapshots()
        .map((data) => Deserializer.deserializeUserCategories(data));
  }

  void setUserCategories(AppUser user, List<String> categories) async {
    await _firestore
        .doc("${FirestorePaths.USERS_COLLECTION}/${user.uid}/")
        .update({"${FirestorePaths.CATEGORIES_SUBPATH}": categories});
  }
}
