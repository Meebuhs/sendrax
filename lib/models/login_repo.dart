import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:sendrax/models/gradeset.dart';
import 'package:sendrax/models/login_response.dart';
import 'package:sendrax/models/user.dart';
import 'package:sendrax/util/constants.dart';
import 'package:sendrax/util/default_grades.dart';

import 'firebase_repo.dart';

class LoginRepo {
  static LoginRepo _instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore;

  LoginRepo._internal(this._firestore);

  factory LoginRepo.getInstance() {
    if (_instance == null) {
      _instance = LoginRepo._internal(FirebaseRepo.getInstance().firestore);
    }
    return _instance;
  }

  Future<LoginResponse> signIn(String username, String password) async {
    String email = await _firestore
        .collection(FirestorePaths.USERNAMES_COLLECTION)
        .document(username)
        .get()
        .then((value) => value.data['email']);
    AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (result != null && result.user != null) {
      return User(result.user.uid);
    } else {
      return LoginFailedResponse();
    }
  }

  Future<LoginResponse> signUp(String username, String email, String password) async {
    AuthResult result =
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (result != null && result.user != null) {
      User user = User(result.user.uid);
      _claimUsername(username, result.user.email, result.user.uid);
      await _firestore
          .collection(FirestorePaths.USERS_COLLECTION)
          .document(result.user.uid)
          .setData(user.map, merge: true);
      _setDefaultGrades(result.user.uid);
      _setDefaultCategories(result.user.uid);
      return user;
    } else {
      return LoginFailedResponse();
    }
  }

  Future<bool> checkUsernameAvailable(String username) async {
    DocumentSnapshot user =
    await _firestore.collection(FirestorePaths.USERNAMES_COLLECTION).document(username).get();
    if (user.exists) {
      throw PlatformException(
          code: "ERROR_USERNAME_TAKEN", message: "A user with this username already exists");
    }
    return (!user.exists);
  }

  void _claimUsername(String username, String email, String uid) async {
    await _firestore
        .collection(FirestorePaths.USERNAMES_COLLECTION)
        .document(username)
        .setData({"username": username, "email": email, "uid": uid});
  }

  void _setDefaultGrades(String userId) async {
    for (GradeSet gradeSet in DefaultGrades.defaultGrades) {
      await _firestore
          .collection("${FirestorePaths.USERS_COLLECTION}/$userId/${FirestorePaths.GRADES_SUBPATH}")
          .document(gradeSet.id)
          .setData(gradeSet.map, merge: true);
    }
  }

  void _setDefaultCategories(String userId) async {
    await _firestore
        .collection(FirestorePaths.USERS_COLLECTION)
        .document(userId)
        .setData({"categories": ClimbCategories.CATEGORIES}, merge: true);
  }

  Future<bool> signOut() async {
    return _auth.signOut().catchError((error) {
      return false;
    }).then((value) {
      return true;
    });
  }

  void resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user;
  }
}
