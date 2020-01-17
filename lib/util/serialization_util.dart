import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/location.dart';

class Deserializer {
  static List<Location> deserializeLocations(List<DocumentSnapshot> locations) {
    return locations.map((document) => deserializeLocation(document)).toList();
  }

  static Location deserializeLocation(DocumentSnapshot document) {
    return Location(document['id'], document['displayName'], List<Climb>());
  }
}
