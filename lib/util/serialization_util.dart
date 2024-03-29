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
    return Location(
        location['id'],
        location['displayName'],
        location['imageUrl'],
        location['imageUri'],
        location['gradeSet'],
        List.from(location['grades']),
        List.from(location['sections']),
        <Climb>[]);
  }

  static List<String> deserializeUserCategories(DocumentSnapshot user) {
    if (user['categories'] != null) {
      return List.from(user['categories']);
    } else {
      return <String>[];
    }
  }

  static List<Climb> deserializeClimbs(List<DocumentSnapshot> climbs) {
    return climbs.map((climb) => deserializeClimb(climb)).toList();
  }

  // @formatter:off
  static Climb deserializeClimb(DocumentSnapshot climb) {
    return Climb(
        climb['id'],
        climb['displayName'],
        climb['imageUrl'],
        climb['imageUri'],
        climb['locationId'],
        climb['grade'],
        climb['gradeSet'],
        climb['section'],
        climb['archived'],
        climb['sent'],
        climb['repeated'],
        _deserializeClimbCategories(climb['categories']), <Attempt>[]);
  }
  // @formatter:on

  static List<String> _deserializeClimbCategories(List<dynamic> categories) {
    return List.from(categories);
  }

  static Location deserializeLocationSections(DocumentSnapshot locationDocument,
      Location location) {
    if (locationDocument.data != null) {
      if (locationDocument['sections'] != null) {
        location.sections.addAll(List.from(locationDocument['sections']));
      }
    }
    return location;
  }

  static List<Attempt> deserializeAttempts(List<DocumentSnapshot> attempts) {
    return attempts.map((attempt) => _deserializeAttempt(attempt)).toList();
  }

  static List<Attempt> deserializeBatchOfAttempts(List<DocumentSnapshot> attemptDocuments,
      List<Attempt> attempts) {
    attempts.addAll(attemptDocuments.map((attempt) => _deserializeAttempt(attempt)).toList());
    return attempts;
  }

  static Attempt _deserializeAttempt(DocumentSnapshot attempt) {
    return Attempt(
        attempt['id'],
        attempt['climbId'],
        attempt['climbName'],
        attempt['climbGrade'],
        attempt['climbGradeSet'],
        List.from(attempt['climbCategories']),
        attempt['locationId'],
        attempt['timestamp'],
        attempt['sendType'],
        attempt['downclimbed'],
        attempt['notes']);
  }

  static Climb deserializeClimbAttempts(List<DocumentSnapshot> attempts, Climb climb) {
    climb.attempts
        .addAll(deserializeAttempts(attempts)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)));
    return climb;
  }

  static GradeSet deserializeGradeSet(DocumentSnapshot grade) {
    return GradeSet(grade['id'], List.from(grade['grades']));
  }

  static List<String> deserializeGradeSetIds(List<DocumentSnapshot> grades) {
    return grades.map((grade) => _deserializeGradeSetId(grade)).toList();
  }

  static String _deserializeGradeSetId(DocumentSnapshot grade) {
    return grade['id'];
  }
}
