import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/util/constants.dart';

class LocationItem extends StatelessWidget {
  LocationItem({Key key, @required this.location}) : super(key: key);

  final Location location;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (location.imagePath != "") {
      content = Column(children: <Widget>[
        Expanded(
          child: Container(
            child: CachedNetworkImage(
              imageUrl: location.imagePath,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(Radius.circular(UIConstants.SMALLER_BORDER_RADIUS)),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    )),
              ),
              placeholder: (context, url) => SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(
                      child: CircularProgressIndicator(
                    strokeWidth: 4.0,
                  ))),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(0.0, UIConstants.SMALLER_PADDING, 0.0, 0.0),
            child: Text(
              location.displayName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: UIConstants.BIGGER_FONT_SIZE, color: Colors.pinkAccent),
            )),
      ]);
    } else {
      content = Text(
        location.displayName,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: UIConstants.BIGGER_FONT_SIZE, color: Colors.pinkAccent),
      );
    }

    return Center(
      child: Container(padding: EdgeInsets.all(UIConstants.SMALLER_PADDING), child: content),
    );
  }
}
