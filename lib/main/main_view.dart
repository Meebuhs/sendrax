import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/history/history_view.dart';
import 'package:sendrax/log/log_view.dart';
import 'package:sendrax/main/main_state.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/models/login_repo.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/stats/stats_view.dart';

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
        create: (context) => MainBloc(),
        child: MainWidget(widget: widget, widgetState: this));
  }
}

class MainWidget extends StatelessWidget {
  const MainWidget({Key key, @required this.widget, @required this.widgetState})
      : super(key: key);

  final MainScreen widget;
  final _MainState widgetState;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.lock_open), onPressed: () => logout(context))
      ],
      bottom: _buildTabBar(),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      tabs: <Widget>[
        Tab(icon: Icon(Icons.assignment)),
        Tab(icon: Icon(Icons.history)),
        Tab(icon: Icon(Icons.assessment)),
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
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).accentColor),
              ),
            );
          } else {
            Map<String, List<String>> grades = <String, List<String>>{};
            Map<String, String> locationNamesToIds = <String, String>{};
            Map<String, String> locationNamesToGradeSet = <String, String>{};

            for (Location location in state.locations) {
              grades.putIfAbsent(location.gradeSet, () => location.grades);
              locationNamesToIds.putIfAbsent(
                  location.displayName, () => location.id);
              locationNamesToGradeSet.putIfAbsent(
                  location.displayName, () => location.gradeSet);
            }
            return TabBarView(
              children: [
                LogScreen(
                    locations: state.locations, categories: state.categories),
                HistoryScreen(
                  attempts: state.attempts,
                  locations: state.locations,
                  categories: state.categories,
                  locationNamesToIds: locationNamesToIds,
                  grades: grades,
                ),
                StatsScreen(
                  attempts: state.attempts.reversed.toList(),
                  categories: state.categories,
                  locationNamesToIds: locationNamesToIds,
                  locationNamesToGradeSet: locationNamesToGradeSet,
                  grades: grades,
                ),
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
