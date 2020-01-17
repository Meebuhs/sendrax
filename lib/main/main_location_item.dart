import 'package:flutter/material.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/util/constants.dart';

class LocationItem extends StatelessWidget {
  LocationItem({Key key, @required this.location}) : super(key: key);

  final Location location;

  @override
  Widget build(BuildContext context) {
    return Center(
          child: Container(
            padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
            child: Text(
              location.displayName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: UIConstants.BIGGER_FONT_SIZE,
                  color: Colors.blueAccent),
            ),
          ),
    );
  }
}
