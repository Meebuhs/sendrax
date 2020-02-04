import 'package:cloud_firestore/cloud_firestore.dart';

class Attempt {
  Attempt(this.id, this.timestamp, this.sendType, this.downclimbed, this.notes);

  final String id;
  final Timestamp timestamp;
  final String sendType;
  final bool downclimbed;
  final String notes;

  Map<String, dynamic> get map {
    return {
      "id": id,
      "timestamp": timestamp,
      "sendType": sendType,
      "downclimbed": downclimbed,
      "notes": notes,
    };
  }
}
