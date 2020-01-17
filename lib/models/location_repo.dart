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

  Future<SelectedLocation> getLocation(Location location, User user) async {
    DocumentReference locationRef = _firestore
        .document("${FirestorePaths.ROOT_PATH}/${user.uid}/${location.id}");
    if (locationRef != null) {
      try {
        return SelectedLocation(location.id, location.displayName);
      } catch (error) {
        print(error);
        return null;
      }
    } else {
      return null;
    }
  }

  Stream<Location> getClimbsForLocation(String locationId, User user) {
    return _firestore
        .collection("${FirestorePaths.ROOT_PATH}/${user.uid}")
        .document(locationId)
        .snapshots()
        .map((data) {
      return Deserializer.deserializeLocationClimbs(
          data);
    });
  }

}
