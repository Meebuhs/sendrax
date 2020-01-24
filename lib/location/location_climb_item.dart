import 'package:flutter/material.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/util/constants.dart';

class ClimbItem extends StatelessWidget {
  ClimbItem({Key key, @required this.climb}) : super(key: key);

  final Climb climb;

  @override
  Widget build(BuildContext context) {
    String label;

    if (climb.displayName == "") {
      if (climb.categories.isEmpty) {
        label = "${climb.grade}";
      } else {
        label = "${climb.grade} - ${climb.categories.join(', ')}";
      }
    } else {
      label = "${climb.grade} - ${climb.displayName}";
    }

    return Center(
      child: Container(
        padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: UIConstants.BIGGER_FONT_SIZE, color: Colors.pinkAccent),
        ),
      ),
    );
  }
}
