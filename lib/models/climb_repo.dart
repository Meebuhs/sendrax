import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/user_repo.dart';
import 'package:sendrax/util/constants.dart';
import 'package:sendrax/util/serialization_util.dart';

import 'firebase_repo.dart';
import 'user.dart';

class ClimbRepo {
  static ClimbRepo _instance;

  final Firestore _firestore;

  ClimbRepo._internal(this._firestore);

  factory ClimbRepo.getInstance() {
    if (_instance == null) {
      _instance = ClimbRepo._internal(FirebaseRepo.getInstance().firestore);
    }
    return _instance;
  }

  Future<SelectedClimb> getClimb(Climb climb, User user) async {
    DocumentReference climbRef = _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.CLIMBS_SUBPATH}")
        .document(climb.id);
    if (climbRef != null) {
      try {
        return SelectedClimb(climb.id, climb.displayName);
      } catch (error) {
        return null;
      }
    } else {
      return null;
    }
  }

  Stream<List<Attempt>> getAttemptsForClimb(String climbId, User user) {
    return _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.CLIMBS_SUBPATH}/$climbId/${FirestorePaths.ATTEMPTS_SUBPATH}")
        .snapshots()
        .map((data) {
      return Deserializer.deserializeAttempts(data.documents);
    });
  }

  void setClimb(Climb climb) async {
    final user = await UserRepo.getInstance().getCurrentUser();
    await _firestore
        .collection(
        "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.CLIMBS_SUBPATH}")
        .document(climb.id)
        .setData(climb.map, merge: true);
  }
}
