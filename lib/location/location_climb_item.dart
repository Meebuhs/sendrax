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
        label = "${climb.grade} - ${(climb.categories..sort()).join(', ')}";
      }
    } else {
      if (climb.categories.isEmpty) {
        label = "${climb.grade} - ${climb.displayName}";
      } else {
        label = "${climb.grade} - ${climb.displayName} - ${(climb.categories..sort()).join(', ')}";
      }
    }

    return Container(
      padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).accentTextTheme.subtitle2,
      ),
    );
  }
}
