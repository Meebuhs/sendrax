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
    Color accentColour = Color(0xffffbec2);
    return MaterialApp(
        title: 'sendrax',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Color(0xfffb8d98),
          accentColor: accentColour,
          backgroundColor: Color(0x00000000),
          cardColor: Color(0xff1f1f1f),
          primaryTextTheme: TextTheme(
            headline5: TextStyle(fontSize: 20.0, color: Colors.black),
            headline6: TextStyle(fontSize: 16.0, color: Colors.black),
            bodyText1: TextStyle(fontSize: 12.0, color: Colors.black),
          ),
          accentTextTheme: TextTheme(
            headline5: TextStyle(fontSize: 20.0, color: accentColour),
            headline6: TextStyle(fontSize: 16.0, color: accentColour),
            bodyText1: TextStyle(fontSize: 12.0, color: accentColour),
          ),
        ),
        home: LoginScreen(),
        navigatorKey: key);
  }

  @override
  void dispose() {
    super.dispose();
  }
}