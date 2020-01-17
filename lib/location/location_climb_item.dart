import 'package:flutter/material.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/util/constants.dart';

class ClimbItem extends StatelessWidget {
  ClimbItem({Key key, @required this.climb}) : super(key: key);

  final Climb climb;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
        child: Text(
          "${climb.grade} - ${climb.section}",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: UIConstants.BIGGER_FONT_SIZE, color: Colors.pinkAccent),
        ),
      ),
    );
  }
}
