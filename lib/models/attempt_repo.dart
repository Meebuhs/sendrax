import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/user_repo.dart';
import 'package:sendrax/util/constants.dart';
import 'package:sendrax/util/serialization_util.dart';

import 'climb.dart';
import 'firebase_repo.dart';
import 'user.dart';

class AttemptRepo {
  static AttemptRepo _instance;

  final FirebaseFirestore _firestore;

  AttemptRepo._internal(this._firestore);

  factory AttemptRepo.getInstance() {
    if (_instance == null) {
      _instance = AttemptRepo._internal(FirebaseRepo.getInstance().firestore);
    }
    return _instance;
  }

  Stream<List<Attempt>> getAttempts(AppUser user) {
    return _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.ATTEMPTS_SUBPATH}")
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((data) {
      return Deserializer.deserializeAttempts(data.docs);
    });
  }

  void setAttempt(Attempt attempt, Climb climb) async {
    final user = await UserRepo.getInstance().getCurrentUser();
    await _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.CLIMBS_SUBPATH}/${attempt.climbId}/${FirestorePaths.ATTEMPTS_SUBPATH}")
        .doc(attempt.id)
        .set(attempt.map, SetOptions(merge: true));
    // Store duplicate in attempts collection for use in log and stats
    await _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.ATTEMPTS_SUBPATH}")
        .doc(attempt.id)
        .set(attempt.map, SetOptions(merge: true));
  }

  void deleteAttempt(String attemptId, String climbId) async {
    final user = await UserRepo.getInstance().getCurrentUser();
    await _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.CLIMBS_SUBPATH}/$climbId/${FirestorePaths.ATTEMPTS_SUBPATH}")
        .doc(attemptId)
        .delete();
    await _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.ATTEMPTS_SUBPATH}")
        .doc(attemptId)
        .delete();
  }
}
