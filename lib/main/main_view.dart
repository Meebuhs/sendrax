import 'package:flutter/material.dart';
import 'package:sendrax/log/log_view.dart';
import 'package:sendrax/models/login_repo.dart';
import 'package:sendrax/navigation_helper.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('sendrax'),
      actions: <Widget>[IconButton(icon: Icon(Icons.lock_open), onPressed: () => logout(context))],
    );
  }

  Widget _buildBody(BuildContext context) {
    return LogScreen();
  }

  void logout(BuildContext context) {
    LoginRepo.getInstance().signOut().then((success) {
      if (success) {
        navigateToLogin(context);
      }
    });
  }

  void navigateToLogin(BuildContext context) {
    NavigationHelper.navigateToLogin(context);
  }
}
