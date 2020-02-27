import 'package:cloud_firestore/cloud_firestore.dart';

class Attempt {
  Attempt(
      this.id,
      this.climbId,
      this.climbName,
      this.climbGrade,
      this.climbGradeSet,
      this.climbCategories,
      this.locationId,
      this.timestamp,
      this.sendType,
      this.downclimbed,
      this.notes);

  final String id;
  final String climbId;
  final String climbName;
  final String climbGrade;
  final String climbGradeSet;
  final List<String> climbCategories;
  final String locationId;
  final Timestamp timestamp;
  final String sendType;
  final bool downclimbed;
  final String notes;

  Map<String, dynamic> get map {
    return {
      "id": id,
      "climbId": climbId,
      "climbName": climbName,
      "climbGrade": climbGrade,
      "climbGradeSet": climbGradeSet,
      "climbCategories": climbCategories,
      "locationId": locationId,
      "timestamp": timestamp,
      "sendType": sendType,
      "downclimbed": downclimbed,
      "notes": notes,
    };
  }

  bool operator ==(o) => o is Attempt && o.id == id;

  int get hashCode => id.hashCode;
}
