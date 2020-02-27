import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/storage_repo.dart';
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

  Stream<Climb> getClimbFromId(String climbId, User user) {
    return _firestore
        .document(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.CLIMBS_SUBPATH}/$climbId")
        .snapshots()
        .map((data) {
      return Deserializer.deserializeClimb(data);
    });
  }

  Stream<Climb> getAttemptsForClimb(Climb climb, User user) {
    return _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.CLIMBS_SUBPATH}/${climb.id}/${FirestorePaths.ATTEMPTS_SUBPATH}")
        .snapshots()
        .map((data) {
      return Deserializer.deserializeClimbAttempts(data.documents, climb);
    });
  }

  Stream<List<Attempt>> getAttemptsByClimbId(String climbId, User user) {
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

  void deleteClimb(String climbId, String imageUri) async {
    final user = await UserRepo.getInstance().getCurrentUser();
    // Delete all attempts contained in this climb
    final WriteBatch batch = _firestore.batch();
    int docCounter = 0;
    QuerySnapshot attempts = await _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.CLIMBS_SUBPATH}/$climbId/${FirestorePaths.ATTEMPTS_SUBPATH}")
        .getDocuments();
    attempts.documents.forEach((attempt) async {
      docCounter++;
      batch.delete(attempt.reference);
      if (docCounter > 498) {
        // batches can delete 500 refs at a time
        await batch.commit();
        docCounter = 0;
      }
    });

    // Delete attempts associated with this climb
    attempts = await _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.ATTEMPTS_SUBPATH}")
        .where("climbId", isEqualTo: climbId)
        .getDocuments();
    attempts.documents.forEach((attempt) async {
      docCounter++;
      batch.delete(attempt.reference);
      if (docCounter > 498) {
        // batches can delete 500 refs at a time
        await batch.commit();
        docCounter = 0;
      }
    });
    await batch.commit();

    await _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.CLIMBS_SUBPATH}")
        .document(climbId)
        .delete();

    if (imageUri != "") {
      StorageRepo.getInstance().deleteFileByUri(imageUri);
    }
  }

  void setClimbArchived(String climbId, bool archived) async {
    final user = await UserRepo.getInstance().getCurrentUser();
    await _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.CLIMBS_SUBPATH}")
        .document(climbId)
        .updateData({"archived": archived});
  }
}
