import 'package:cloud_firestore/cloud_firestore.dart';

class Attempt {
  Attempt(this.id, this.timestamp, this.sendType, this.warmup, this.drills, this.notes);

  final String id;
  final Timestamp timestamp;
  final String sendType;
  final bool warmup;
  final List<String> drills;
  final String notes;
}
