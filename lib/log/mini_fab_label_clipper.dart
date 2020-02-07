import 'dart:ui';

import 'package:flutter/widgets.dart';

class MiniFabLabelClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..arcToPoint(
        Offset(size.width, size.height),
        clockwise: false,
        radius: Radius.elliptical(20, 20),
      );

    path.lineTo(0.0, size.height);
    path.lineTo(0.0, 0.0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(MiniFabLabelClipper oldClipper) => true;
}
