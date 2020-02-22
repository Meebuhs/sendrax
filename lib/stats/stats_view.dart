import 'package:flutter/material.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/stats/charts/attempts_by_time.dart';

import 'charts/attempts_by_date.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen(
      {Key key,
      @required this.attempts,
      @required this.locations,
      @required this.locationNamesToIds,
      @required this.grades})
      : super(key: key);

  final List<Attempt> attempts;
  final List<Location> locations;
  final Map<String, String> locationNamesToIds;
  final Map<String, List<String>> grades;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2, child: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildTabBar(context),
        Expanded(
          child: _buildTabBarView(),
        )
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return SizedBox(
        height: 50.0,
        width: double.infinity,
        child: Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: TabBar(
                isScrollable: true,
                unselectedLabelColor: Theme.of(context).disabledColor,
                indicatorColor: Theme.of(context).accentColor,
                labelColor: Theme.of(context).accentColor,
                labelStyle: Theme.of(context).accentTextTheme.overline,
                tabs: [
                  Tab(child: Text('ATTEMPTS BY DATE')),
                  Tab(child: Text('ATTEMPTS BY TIME')),
                ])));
  }

  Widget _buildTabBarView() {
    Map<String, String> locationNamesToIds = <String, String>{};
    for (Location location in locations) {
      locationNamesToIds.putIfAbsent(location.displayName, () => location.id);
    }

    return TabBarView(
      children: [
        AttemptsByDateChart(
          attempts: attempts,
          locationNamesToIds: locationNamesToIds,
          grades: grades,
        ),
        AttemptsByTimeChart(
          attempts: attempts,
          locationNamesToIds: locationNamesToIds,
          grades: grades,
        ),
      ],
    );
  }
}
