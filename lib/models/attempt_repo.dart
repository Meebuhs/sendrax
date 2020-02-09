import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/user_repo.dart';
import 'package:sendrax/util/constants.dart';
import 'package:sendrax/util/serialization_util.dart';

import 'firebase_repo.dart';
import 'user.dart';

class AttemptRepo {
  static AttemptRepo _instance;

  final Firestore _firestore;

  AttemptRepo._internal(this._firestore);

  factory AttemptRepo.getInstance() {
    if (_instance == null) {
      _instance = AttemptRepo._internal(FirebaseRepo.getInstance().firestore);
    }
    return _instance;
  }

  Stream<List<Attempt>> getAttempts(User user) {
    return _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.ATTEMPTS_SUBPATH}")
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((data) {
      return Deserializer.deserializeAttempts(data.documents);
    });
  }

  Stream<List<Attempt>> getBatchOfAttempts(List<Attempt> attempts, User user) {
    if (attempts.isEmpty) {
      return _getFirstBatchOfAttempts(attempts, user);
    } else {
      return _getNextBatchOfAttempts(attempts, user);
    }
  }

  Stream<List<Attempt>> _getFirstBatchOfAttempts(List<Attempt> attempts, User user) {
    return _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.ATTEMPTS_SUBPATH}")
        .orderBy('timestamp', descending: true)
        .limit(LazyLoadConstants.BATCH_SIZE)
        .snapshots()
        .map((data) {
      return Deserializer.deserializeBatchOfAttempts(data.documents, attempts);
    });
  }

  Stream<List<Attempt>> _getNextBatchOfAttempts(List<Attempt> attempts, User user) {
    return _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.ATTEMPTS_SUBPATH}")
        .orderBy('timestamp', descending: true)
        .startAfter([attempts.last.timestamp])
        .limit(LazyLoadConstants.BATCH_SIZE)
        .snapshots()
        .map((data) {
          return Deserializer.deserializeBatchOfAttempts(data.documents, attempts);
        });
  }

  Stream<List<Attempt>> getRemainingAttemptsForBatch(List<Attempt> batch, User user) {
    DateTime lastAttemptDate = batch.last.timestamp.toDate();
    DateTime startDate = DateTime(lastAttemptDate.year, lastAttemptDate.month, lastAttemptDate.day);
    DateTime endDate = startDate.add(Duration(days: 1));

    return _firestore
        .collection(
        "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.ATTEMPTS_SUBPATH}")
        .orderBy('timestamp', descending: true)
        .where('timestamp', isGreaterThanOrEqualTo: startDate).where('timestamp', isLessThan: endDate)
        .snapshots()
        .map((data) {
      List<Attempt> remainingAttempts = Deserializer.deserializeBatchOfAttempts(data.documents, <Attempt>[]);
      for (Attempt attempt in remainingAttempts) {
        if (!batch.contains(attempt)) {
          batch.add(attempt);
        }
      }
      return batch;
    });
  }

  void setAttempt(Attempt attempt) async {
    final user = await UserRepo.getInstance().getCurrentUser();
    await _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.CLIMBS_SUBPATH}/${attempt.climbId}/${FirestorePaths.ATTEMPTS_SUBPATH}")
        .document(attempt.id)
        .setData(attempt.map, merge: true);
    // Store duplicate in attempts collection for use in log and stats
    await _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.ATTEMPTS_SUBPATH}")
        .document(attempt.id)
        .setData(attempt.map, merge: true);
  }

  void deleteAttempt(String attemptId, String climbId) async {
    final user = await UserRepo.getInstance().getCurrentUser();
    await _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.CLIMBS_SUBPATH}/$climbId/${FirestorePaths.ATTEMPTS_SUBPATH}")
        .document(attemptId)
        .delete();
    await _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.ATTEMPTS_SUBPATH}")
        .document(attemptId)
        .delete();
  }
}
