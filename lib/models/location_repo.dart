import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/user_repo.dart';
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
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.LOCATIONS_SUBPATH}")
        .snapshots()
        .map((data) => Deserializer.deserializeLocations(data.documents));
  }

  Future<SelectedLocation> getLocation(Location location, User user) async {
    DocumentReference locationRef = _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.LOCATIONS_SUBPATH}")
        .document(location.id);
    if (locationRef != null) {
      try {
        return SelectedLocation(location.id, location.displayName, location.gradesId);
      } catch (error) {
        return null;
      }
    } else {
      return null;
    }
  }

  Stream<List<Climb>> getClimbsForLocation(String locationId, User user) {
    return _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.CLIMBS_SUBPATH}")
        .where("locationId", isEqualTo: locationId)
        .snapshots()
        .map((data) => Deserializer.deserializeClimbs(data.documents));
  }

  Stream<Location> getSectionsForLocation(String locationId, User user) {
    return _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.LOCATIONS_SUBPATH}")
        .document(locationId)
        .snapshots()
        .map((data) {
      return Deserializer.deserializeLocationSections(data);
    });
  }

  void setLocation(Location location) async {
    final user = await UserRepo.getInstance().getCurrentUser();
    await _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.LOCATIONS_SUBPATH}")
        .document(location.id)
        .setData(location.map, merge: true);
  }

  void deleteLocation(String locationId) async {
    final user = await UserRepo.getInstance().getCurrentUser();
    await _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.LOCATIONS_SUBPATH}")
        .document(locationId)
        .delete();

    // Delete all climbs contained in this location
    final WriteBatch batch = _firestore.batch();
    int docCounter = 0;
    QuerySnapshot climbs = await _firestore
        .collection(
            "${FirestorePaths.USERS_COLLECTION}/${user.uid}/${FirestorePaths.CLIMBS_SUBPATH}")
        .where("locationId", isEqualTo: locationId)
        .getDocuments();
    climbs.documents.forEach((climb) async {
      docCounter++;
      batch.delete(climb.reference);
      if (docCounter > 498) { // batches can delete 500 refs at a time
        await batch.commit();
      }
    });
    await batch.commit();
  }
}
