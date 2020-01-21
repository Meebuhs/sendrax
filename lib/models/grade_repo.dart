import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendrax/models/user.dart';
import 'package:sendrax/models/user_repo.dart';
import 'package:sendrax/util/constants.dart';
import 'package:sendrax/util/serialization_util.dart';

import 'firebase_repo.dart';
import 'gradeset.dart';

class GradeRepo {
  static GradeRepo _instance;
  final Firestore _firestore;

  GradeRepo._internal(this._firestore);

  factory GradeRepo.getInstance() {
    if (_instance == null) {
      _instance = GradeRepo._internal(FirebaseRepo.getInstance().firestore);
    }
    return _instance;
  }

  Stream<List<GradeSet>> getGradeSets(User user) {
    return _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.GRADES_SUBPATH}")
        .snapshots()
        .map((data) => Deserializer.deserializeGradeSets(data.documents));
  }

  Stream<List<String>> getGradeIds(User user) {
    return _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.GRADES_SUBPATH}")
        .snapshots()
        .map((data) => Deserializer.deserializeGradeIds(data.documents));
  }

  void setGradeSet(GradeSet gradeSet) async {
    final user = await UserRepo.getInstance().getCurrentUser();
    await _firestore
        .collection(
        "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.GRADES_SUBPATH}")
        .document(gradeSet.id)
        .setData(gradeSet.map, merge: true);
  }
}
