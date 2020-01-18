import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/location.dart';

class Deserializer {
  static List<Location> deserializeLocations(List<DocumentSnapshot> locations) {
    return locations.map((document) => deserializeLocation(document)).toList();
  }

  static Location deserializeLocation(DocumentSnapshot document) {
    return Location(document['id'], document['displayName'], <String>[], <String>[], <Climb>[]);
  }

  static List<Climb> deserializeClimbs(List<DocumentSnapshot> climbs) {
    return climbs.map((document) => deserializeClimb(document)).toList();
  }

  static Climb deserializeClimb(DocumentSnapshot document) {
    return Climb(
        document['id'],
        document['displayName'],
        document['grade'],
        document['locationId'],
        document['section'],
        document['archived'],
        <String>[],
        <Attempt>[]);
  }

  static Location deserializeLocationSections(DocumentSnapshot document) {
    Location location = deserializeLocation(document);
    if (document['sections'] != null) {
      location.sections.addAll(List.from(document['sections']));
    }
    return location;
  }

  static List<Attempt> deserializeAttempts(List<DocumentSnapshot> attempts) {
    return attempts.map((document) => deserializeAttempt(document)).toList();
  }

  static Attempt deserializeAttempt(DocumentSnapshot document) {
    return Attempt(document['id'], document['timestamp'], document['sendType'], document['warmup'],
        <String>[], document['notes']);
  }
}
