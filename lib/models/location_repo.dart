import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendrax/util/constants.dart';
import 'package:sendrax/util/serialization_util.dart';

import 'firebase_repo.dart';
import 'location.dart';
import 'user.dart';

class LocationRepo {
  static LocationRepo _instance;

  final Firestore _firestore;

  LocationRepo._internal(this._firestore);

  factory LocationRepo.getInstance() {
    if (_instance == null) {
      _instance = LocationRepo._internal(FirebaseRepo.getInstance().firestore);
    }
    return _instance;
  }

  Stream<List<Location>> getLocationsForUser(User user) {
    return _firestore
        .collection("${FirestorePaths.ROOT_PATH}/${user.uid}")
        .snapshots()
        .map((data) => Deserializer.deserializeLocations(data.documents));
  }
}
