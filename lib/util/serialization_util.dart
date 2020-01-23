import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/gradeset.dart';
import 'package:sendrax/models/location.dart';

class Deserializer {
  static List<Location> deserializeLocations(List<DocumentSnapshot> locations) {
    return locations.map((location) => _deserializeLocation(location)).toList();
  }

  static Location _deserializeLocation(DocumentSnapshot location) {
    return Location(location['id'], location['displayName'], location['gradesId'], <String>[],
        <String>[], <Climb>[]);
  }

  static List<String> deserializeCategories(DocumentSnapshot user) {
    if (user['categories'] != null) {
      return List.from(user['categories']);
    } else {
      return <String>[];
    }
  }

  static List<Climb> deserializeClimbs(List<DocumentSnapshot> climbs) {
    return climbs.map((climb) => _deserializeClimb(climb)).toList();
  }

  static Climb _deserializeClimb(DocumentSnapshot climb) {
    return Climb(climb['id'], climb['displayName'], climb['locationId'], climb['grade'],
        climb['gradesId'], climb['section'], climb['archived'], <String>[], <Attempt>[]);
  }

  static Location deserializeLocationSections(DocumentSnapshot locationDocument) {
    if (locationDocument.data != null) {
      Location location = _deserializeLocation(locationDocument);
      if (locationDocument['sections'] != null) {
        location.sections.addAll(List.from(locationDocument['sections']));
      }
      return location;
    } else {
      // This occurs when a location is deleted and the pages in the stack try to load it
      // It is discarded immediately and thus an empty placeholder is safe here
      return Location("", "", "", <String>[]);
    }
  }

  static List<Attempt> deserializeAttempts(List<DocumentSnapshot> attempts) {
    return attempts.map((attempt) => _deserializeAttempt(attempt)).toList();
  }

  static Attempt _deserializeAttempt(DocumentSnapshot attempt) {
    return Attempt(attempt['id'], attempt['timestamp'], attempt['sendType'], attempt['warmup'],
        attempt['downclimbed'], attempt['notes']);
  }

  static List<GradeSet> deserializeGradeSets(List<DocumentSnapshot> grades) {
    return grades.map((grade) => deserializeGradeSet(grade)).toList();
  }

  static GradeSet deserializeGradeSet(DocumentSnapshot grade) {
    return GradeSet(grade['displayName'], List.from(grade['grades']));
  }

  static List<String> deserializeGradeIds(List<DocumentSnapshot> grades) {
    return grades.map((grade) => _deserializeGradeId(grade)).toList();
  }

  static String _deserializeGradeId(DocumentSnapshot grade) {
    return grade['id'];
  }
}
