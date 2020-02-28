import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sendrax/navigation_helper.dart';

class ImageScreen extends StatelessWidget {
  const ImageScreen({Key key, @required this.image}) : super(key: key);

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: InkWell(
      child: Container(
          child: PhotoView(
        imageProvider: image,
        minScale: PhotoViewComputedScale.contained,
        heroAttributes: PhotoViewHeroAttributes(tag: "imageHero"),
      )),
      onTap: () => NavigationHelper.navigateBackOne(context),
    ));
  }
}
