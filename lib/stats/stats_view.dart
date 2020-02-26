import 'package:flutter/material.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/stats/charts/attempts_to_send.dart';
import 'package:sendrax/stats/charts/downclimbed_by_grade.dart';
import 'package:sendrax/stats/charts/repeats_by_grade.dart';

import 'charts/attempts_by_date.dart';
import 'charts/attempts_by_grade.dart';
import 'charts/attempts_by_value/attempt_by_category.dart';
import 'charts/attempts_by_value/attempts_by_day.dart';
import 'charts/attempts_by_value/attempts_by_location.dart';
import 'charts/attempts_by_value/attempts_by_time.dart';
import 'charts/grade_by_sendtype.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen(
      {Key key,
      @required this.attempts,
      @required this.locations,
      @required this.categories,
      @required this.locationNamesToIds,
      @required this.grades})
      : super(key: key);

  final List<Attempt> attempts;
  final List<Location> locations;
  final List<String> categories;
  final Map<String, String> locationNamesToIds;
  final Map<String, List<String>> grades;

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, Widget> tabs;

  @override
  void initState() {
    tabs = {
      "ATTEMPTS BY DATE": AttemptsByDateChart(
        attempts: widget.attempts,
        categories: widget.categories,
        grades: widget.grades,
        locationNamesToIds: widget.locationNamesToIds,
      ),
      "ATTEMPTS BY DAY": AttemptsByDayChart(
        attempts: widget.attempts,
        categories: widget.categories,
        grades: widget.grades,
        locationNamesToIds: widget.locationNamesToIds,
      ),
      "ATTEMPTS BY TIME": AttemptsByTimeChart(
        attempts: widget.attempts,
        categories: widget.categories,
        grades: widget.grades,
        locationNamesToIds: widget.locationNamesToIds,
      ),
      "ATTEMPTS BY GRADE": AttemptsByGradeChart(
        attempts: widget.attempts,
        categories: widget.categories,
        grades: widget.grades,
        locationNamesToIds: widget.locationNamesToIds,
      ),
      "ATTEMPTS TO SEND": AttemptsToSendChart(
        attempts: widget.attempts,
        categories: widget.categories,
        grades: widget.grades,
        locationNamesToIds: widget.locationNamesToIds,
      ),
      "REPEATS BY GRADE": RepeatsByGradeChart(
        attempts: widget.attempts,
        categories: widget.categories,
        grades: widget.grades,
        locationNamesToIds: widget.locationNamesToIds,
      ),
      "DOWNCLIMBED BY GRADE": DownclimbedByGradeChart(
        attempts: widget.attempts,
        categories: widget.categories,
        grades: widget.grades,
        locationNamesToIds: widget.locationNamesToIds,
      ),
      "ATTEMPTS BY LOCATION": AttemptsByLocationChart(
        attempts: widget.attempts,
        categories: widget.categories,
        grades: widget.grades,
        locationNamesToIds: widget.locationNamesToIds,
      ),
      "ATTEMPTS BY CATEGORY": AttemptsByCategoryChart(
        attempts: widget.attempts,
        categories: widget.categories,
        grades: widget.grades,
        locationNamesToIds: widget.locationNamesToIds,
      ),
      "HIGHEST GRADE BY SEND TYPE": GradeBySendTypeChart(
        attempts: widget.attempts,
        categories: widget.categories,
        grades: widget.grades,
        locationNamesToIds: widget.locationNamesToIds,
        average: false,
      ),
      "AVERAGE GRADE BY SEND TYPE": GradeBySendTypeChart(
        attempts: widget.attempts,
        categories: widget.categories,
        grades: widget.grades,
        locationNamesToIds: widget.locationNamesToIds,
        average: true,
      )
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: tabs.keys.length, child: _buildBody(context, tabs));
  }

  Widget _buildBody(BuildContext context, Map<String, Widget> tabs) {
    return Column(
      children: <Widget>[
        _buildTabBar(context, tabs),
        Expanded(
          child: _buildTabBarView(tabs),
        )
      ],
    );
  }

  Widget _buildTabBar(BuildContext context, Map<String, Widget> tabs) {
    List<Widget> tabWidgets = <Widget>[];
    tabs.forEach((key, value) => tabWidgets.add(Tab(child: Text(key))));

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
                tabs: tabWidgets)));
  }

  Widget _buildTabBarView(Map<String, Widget> tabs) {
    Map<String, String> locationNamesToIds = <String, String>{};
    for (Location location in widget.locations) {
      locationNamesToIds.putIfAbsent(location.displayName, () => location.id);
    }

    List<Widget> tabViews = <Widget>[];
    tabs.forEach((key, value) => tabViews.add(value));

    return TabBarView(
      children: tabViews,
    );
  }
}
