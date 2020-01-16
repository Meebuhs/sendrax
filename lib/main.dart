import 'package:flutter/material.dart';

import 'login/login_view.dart';

void main() => runApp(sendrax());

class sendrax extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _sendraxState();
}

class _sendraxState extends State<sendrax> {
  final key = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'sendrax',
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
        home: LoginScreen(),
        navigatorKey: key);
  }

  @override
  void dispose() {
    super.dispose();
  }
}