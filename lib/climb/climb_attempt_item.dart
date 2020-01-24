import 'package:flutter/material.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/climb_repo.dart';
import 'package:sendrax/util/constants.dart';

class AttemptItem extends StatelessWidget {
  AttemptItem({Key key, @required this.attempt, @required this.climbId}) : super(key: key);

  final Attempt attempt;
  final String climbId;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: Key(attempt.id),
        direction: DismissDirection.endToStart,
        background: Container(
            color: Colors.red,
            child: (Container(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, UIConstants.SMALLER_PADDING, 0.0),
                child: Icon(Icons.delete_forever, color: Colors.white),
              ),
              alignment: Alignment.centerRight,
            ))),
        onDismissed: (direction) => ClimbRepo.getInstance().deleteAttempt(attempt.id, climbId),
        child: ListTile(
            title: Text(
              "${formatDate(attempt.timestamp.toDate())} ${attempt.sendType}",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: UIConstants.STANDARD_FONT_SIZE, color: Colors.pinkAccent),
            ),
            subtitle: Text(attempt.notes),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[_showWarmupTick(), _showDownclimbedTick()],
            )));
  }

  Widget _showWarmupTick() {
    return Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Text(
        "W: ",
        style: TextStyle(fontSize: UIConstants.STANDARD_FONT_SIZE, color: Colors.grey),
      ),
      (attempt.warmup)
          ? Icon(
              Icons.check,
              color: Colors.grey,
              size: UIConstants.STANDARD_FONT_SIZE,
            )
          : Icon(
              Icons.close,
              color: Colors.grey,
              size: UIConstants.STANDARD_FONT_SIZE,
            )
    ]);
  }

  Widget _showDownclimbedTick() {
    return Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Text(
        "D: ",
        style: TextStyle(fontSize: UIConstants.STANDARD_FONT_SIZE, color: Colors.grey),
      ),
      (attempt.downclimbed)
          ? Icon(
              Icons.check,
              color: Colors.grey,
              size: UIConstants.STANDARD_FONT_SIZE,
            )
          : Icon(
              Icons.close,
              color: Colors.grey,
              size: UIConstants.STANDARD_FONT_SIZE,
            )
    ]);
  }

  String formatDate(DateTime time) {
    String ampm = (time.hour < 12) ? "AM" : "PM";
    return "${time.day}/${time.month} ${time.hour % 12}:${time.minute.toString().padLeft(2, '0')} $ampm";
  }
}
