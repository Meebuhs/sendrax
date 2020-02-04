import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/util/constants.dart';

class LocationItem extends StatelessWidget {
  LocationItem(
      {Key key, @required this.location, @required this.categories, @required this.onTapped})
      : super(key: key);

  final Location location;
  final List<String> categories;
  final Function(Location, List<String>) onTapped;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
        child: Card(
            color: Theme.of(context).cardColor,
            child: InkWell(
              child: _buildContent(location, context),
              onTap: () => onTapped(location, categories),
            )),
      ),
    );
  }

  Widget _buildContent(Location location, BuildContext context) {
    if (location.imagePath != "") {
      return _buildImageContent(location, context);
    } else {
      return _buildTextContent(location, context);
    }
  }

  Widget _buildImageContent(Location location, BuildContext context) {
    return Column(children: <Widget>[
      Expanded(
        child: Container(
          child: Padding(
            padding: EdgeInsets.all(1.0),
            child: CachedNetworkImage(
              imageUrl: location.imagePath,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(UIConstants.CARD_BORDER_RADIUS)),
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
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: UIConstants.SMALLER_PADDING),
        child: _showText(location, context),
      )
    ]);
  }

  Widget _buildTextContent(Location location, BuildContext context) {
    return Container(child: Center(child: _showText(location, context)));
  }

  Widget _showText(Location location, BuildContext context) {
    return Text(
      location.displayName,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).accentTextTheme.headline6,
    );
  }
}
