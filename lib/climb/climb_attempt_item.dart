import 'package:flutter/material.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

class AttemptItem extends StatelessWidget {
  AttemptItem({Key key, @required this.attempt}) : super(key: key);

  final Attempt attempt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
      child: Text(
        "${attempt.sendType}",
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: UIConstants.BIGGER_FONT_SIZE, color: Colors.pinkAccent),
      ),
    );
  }
}
