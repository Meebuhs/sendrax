import 'package:cloud_firestore/cloud_firestore.dart';

class Attempt {
  Attempt(this.id, this.climbId, this.locationId, this.grade, this.timestamp, this.sendType,
      this.downclimbed, this.notes);

  final String id;
  final String climbId;
  final String locationId;
  final String grade;
  final Timestamp timestamp;
  final String sendType;
  final bool downclimbed;
  final String notes;

  Map<String, dynamic> get map {
    return {
      "id": id,
      "climbId": climbId,
      "locationId": locationId,
      "grade": grade,
      "timestamp": timestamp,
      "sendType": sendType,
      "downclimbed": downclimbed,
      "notes": notes,
    };
  }
}
