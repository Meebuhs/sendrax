import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/location.dart';

class Deserializer {
  static List<Location> deserializeLocations(List<DocumentSnapshot> locations) {
    return locations.map((document) => deserializeLocation(document)).toList();
  }

  static Location deserializeLocation(DocumentSnapshot document) {
    return Location(
        document['id'], document['displayName'], <String>[], <String>[],
        <Climb>[]);
  }

  static Location deserializeLocationClimbs(DocumentSnapshot document) {
    Location location = deserializeLocation(document);
    location.climbs.addAll(deserializeClimbs(document['climbs']));
    return location;
  }

  static List<Climb> deserializeClimbs(List<dynamic> climbs) {
    return climbs.map((document) => deserializeClimb(document))
        .toList();
  }

  static Climb deserializeClimb(Map<dynamic, dynamic> document) {
    return Climb(
        document['grade'], document['section'], <String>[], <Attempt>[]);
  }
}
