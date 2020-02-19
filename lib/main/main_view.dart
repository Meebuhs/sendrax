import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/history/history_view.dart';
import 'package:sendrax/log/log_view.dart';
import 'package:sendrax/main/main_state.dart';
import 'package:sendrax/models/login_repo.dart';
import 'package:sendrax/navigation_helper.dart';

import 'main_bloc.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainState();
}

class _MainState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<MainBloc>(
        create: (context) => MainBloc(), child: MainWidget(widget: widget, widgetState: this));
  }
}

class MainWidget extends StatelessWidget {
  const MainWidget({Key key, @required this.widget, @required this.widgetState}) : super(key: key);

  final MainScreen widget;
  final _MainState widgetState;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('sendrax'),
      actions: <Widget>[IconButton(icon: Icon(Icons.lock_open), onPressed: () => logout(context))],
      bottom: _buildTabBar(context),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return TabBar(
      tabs: <Widget>[
        Tab(icon: Icon(Icons.assignment)),
        Tab(icon: Icon(Icons.history)),
      ],
      indicatorColor: Colors.black,
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<MainBloc>(context),
        builder: (context, MainState state) {
          if (state.loading) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 4.0,
              ),
            );
          } else {
            return TabBarView(
              children: [
                LogScreen(locations: state.locations, categories: state.categories),
                HistoryScreen(
                    attempts: state.attempts,
                    locations: state.locations,
                    categories: state.categories),
              ],
            );
          }
        });
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
