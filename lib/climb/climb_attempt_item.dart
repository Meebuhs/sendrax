import 'package:flutter/material.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

class AttemptItem extends StatelessWidget {
  AttemptItem({Key key, @required this.attempt}) : super(key: key);

  final Attempt attempt;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "${formatDate(attempt.timestamp.toDate())} ${attempt.sendType}",
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: UIConstants.STANDARD_FONT_SIZE, color: Colors.pinkAccent),
      ),
      subtitle: Text(attempt.notes)
    );
  }

  String formatDate(DateTime time) {
    String ampm = (time.hour < 12) ? "AM" : "PM";
    return "${time.day}/${time.month} ${time.hour % 12}:${time.minute.toString().padLeft(2, '0')} $ampm";
  }
}
