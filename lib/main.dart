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
    Color primaryColour = Color(0xfffb8d98);
    Color accentColour = Color(0xffffbec2);
    Color errorColour = Color(0xfffb4753);
    return MaterialApp(
        title: 'sendrax',
        theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: primaryColour,
            accentColor: accentColour,
            errorColor: errorColour,
            backgroundColor: Color(0x00000000),
            cardColor: Color(0xff1f1f1f),
            canvasColor: Color(0xff1f1f1f),
            primaryTextTheme: TextTheme(
              headline5: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0),
              headline6: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.15),
              button: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.25),
              bodyText1: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5),
              bodyText2: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.25),
            ),
            accentTextTheme: TextTheme(
              headline5: TextStyle(
                  fontSize: 20.0,
                  color: accentColour,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0),
              headline6: TextStyle(
                  fontSize: 18.0,
                  color: accentColour,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.15),
              button: TextStyle(
                  fontSize: 14.0,
                  color: accentColour,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.25),
              subtitle1: TextStyle(
                  fontSize: 16.0,
                  color: accentColour,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.15),
              subtitle2: TextStyle(
                  fontSize: 14.0,
                  color: accentColour,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1),
              bodyText1: TextStyle(
                  fontSize: 16.0,
                  color: accentColour,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5),
              bodyText2: TextStyle(
                  fontSize: 14.0,
                  color: accentColour,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.25),
              caption: TextStyle(
                  fontSize: 12.0,
                  color: accentColour,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.4),
            ),
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: accentColour, width: 1.5),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0x00000000), width: 0.0),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: errorColour, width: 1.5),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: errorColour, width: 1.5),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              errorStyle: TextStyle(fontSize: 12.0, color: errorColour, letterSpacing: 0.4),
            )),
        home: LoginScreen(),
        navigatorKey: key);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
