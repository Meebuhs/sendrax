import 'package:flutter/material.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/util/constants.dart';

class ClimbItem extends StatelessWidget {
  ClimbItem({Key key, @required this.climb}) : super(key: key);

  final Climb climb;

  @override
  Widget build(BuildContext context) {
    String label = createLabel();

    Widget statusIcon = createStatusIcon(context);

    return Container(
        padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
        child: Row(children: <Widget>[
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme
                  .of(context)
                  .accentTextTheme
                  .subtitle2,
            ),
          ),
          Container(
            // Archive section icon is 24px, status icon is 14px, 5px padding to align them
            padding: EdgeInsets.only(right: 5),
            child: statusIcon,
          ),
        ]));
  }

  String createLabel() {
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
    return label;
  }

  Widget createStatusIcon(BuildContext context) {
    IconData statusIcon;

    if (climb.repeated) {
      statusIcon = Icons.rotate_right;
    } else if (climb.sent) {
      statusIcon = Icons.check;
    }

    return Icon(
      statusIcon,
      color: Theme
          .of(context)
          .accentColor,
      size: Theme
          .of(context)
          .accentTextTheme
          .subtitle2
          .fontSize,
    );
  }
}
