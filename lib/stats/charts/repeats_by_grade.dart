import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

import 'attempt_filter.dart';

class RepeatsByGradeChart extends StatefulWidget {
  RepeatsByGradeChart(
      {Key key,
      @required this.attempts,
      @required this.categories,
      @required this.grades,
      @required this.locationNamesToIds})
      : super(key: key);
  final List<Attempt> attempts;
  final List<String> categories;
  final Map<String, List<String>> grades;
  final Map<String, String> locationNamesToIds;

  @override
  _RepeatsByGradeChartState createState() => _RepeatsByGradeChartState();
}

class _RepeatsByGradeChartState extends State<RepeatsByGradeChart> {
  StreamController<List<Attempt>> filteredAttemptsStream;
  StreamSubscription<List<Attempt>> filteredAttemptsListener;
  StreamController<String> gradeSetFilterStream;
  StreamSubscription<String> gradeSetFilterListener;
  String filterGradeSet;
  List<charts.Series> chartSeries;

  @override
  void initState() {
    filteredAttemptsStream = StreamController<List<Attempt>>.broadcast();
    filteredAttemptsListener = filteredAttemptsStream.stream.listen((filteredAttempts) {
      setState(() {
        if (filterGradeSet != null) {
          chartSeries = _buildChartSeries(context, filteredAttempts);
        }
      });
    });
    gradeSetFilterStream = StreamController<String>.broadcast();
    gradeSetFilterListener = gradeSetFilterStream.stream.listen((filterValue) {
      setState(() {
        filterGradeSet = filterValue;
      });
    });
    if (widget.grades.keys.length == 1) {
      filterGradeSet = widget.grades.keys.first;
      chartSeries = _buildChartSeries(context, widget.attempts);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
        child: Column(children: <Widget>[
          AttemptFilter(
            attempts: widget.attempts,
            categories: widget.categories,
            locationNamesToIds: widget.locationNamesToIds,
            filteredAttemptsStream: filteredAttemptsStream,
            enableFilters: [
              FilterType.gradeSet,
              FilterType.timeframe,
              FilterType.location,
              FilterType.category
            ],
            gradeSetFilterStream: gradeSetFilterStream,
            grades: widget.grades,
          ),
          _buildChart(context),
        ]));
  }

  Widget _buildChart(BuildContext context) {
    Widget content;
    if (filterGradeSet != null) {
      if (chartSeries != null) {
        content = charts.BarChart(
          chartSeries,
          primaryMeasureAxis: charts.NumericAxisSpec(
              renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: Theme.of(context).accentTextTheme.caption.fontSize.toInt(),
              fontWeight: Theme.of(context).accentTextTheme.caption.fontWeight.toString(),
              color: charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
            ),
            lineStyle: charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(Theme.of(context).dialogBackgroundColor),
            ),
          )),
          domainAxis: charts.OrdinalAxisSpec(
            renderSpec: charts.SmallTickRendererSpec(
              lineStyle: charts.LineStyleSpec(
                color: charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
              ),
              labelStyle: charts.TextStyleSpec(
                fontSize: Theme.of(context).accentTextTheme.caption.fontSize.toInt(),
                fontWeight: Theme.of(context).accentTextTheme.caption.fontWeight.toString(),
                color: charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
              ),
            ),
            tickProviderSpec: charts.StaticOrdinalTickProviderSpec(_buildTicks()),
          ),
          barGroupingType: charts.BarGroupingType.stacked,
          defaultInteractions: false,
        );
      } else {
        content = Center(
            child: Text(
          "There are no existing attempts ${widget.attempts.isNotEmpty ? "matching these filters" : ""}. \nGo log some!",
          style: Theme.of(context).accentTextTheme.subtitle2,
          textAlign: TextAlign.center,
        ));
      }
    } else {
      content = Center(
          child: Text(
        "You must select a grade set to generate this graph",
        style: Theme.of(context).accentTextTheme.subtitle2,
        textAlign: TextAlign.center,
      ));
    }

    return Expanded(
        child: Container(
            padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.all(Radius.circular(UIConstants.CARD_BORDER_RADIUS))),
            child: content));
  }

  List<charts.Series<RepeatsByGradeSeries, String>> _buildChartSeries(
      BuildContext context, List<Attempt> filteredAttempts) {
    if (filteredAttempts.isEmpty) {
      return null;
    }

    Map<String, List<Attempt>> climbs = <String, List<Attempt>>{};

    for (Attempt attempt in filteredAttempts) {
      if (attempt.id == "attempt-0debf510-4881-11ea-a39c-f3ce90f074e8") {
        print("found attempt");
      }
      String climbId = attempt.climbId;
      if (climbs.containsKey(climbId)) {
        climbs.update(climbId, (value) => value..add(attempt));
      } else {
        climbs.putIfAbsent(climbId, () => [attempt]);
      }
    }

    Map<String, List<int>> attemptsByGrade = <String, List<int>>{};
    for (String grade in widget.grades[filterGradeSet]) {
      attemptsByGrade.putIfAbsent(grade, () => <int>[]);
    }

    for (String climbId in climbs.keys) {
      if (climbs[climbId]
          .any((attempt) => ["Onsight", "Flash", "Send"].contains(attempt.sendType))) {
        attemptsByGrade.update(
            climbs[climbId].first.climbGrade,
            (value) => value
              ..add(climbs[climbId].where((attempt) => attempt.sendType == "Repeat").length));
      }
    }

    List<RepeatsByGradeSeries> chartData = <RepeatsByGradeSeries>[];
    for (String grade in widget.grades[filterGradeSet]) {
      if (attemptsByGrade[grade].isNotEmpty) {
        chartData.add(RepeatsByGradeSeries(
            grade, attemptsByGrade[grade].reduce((a, b) => a + b) / attemptsByGrade[grade].length));
      } else {
        chartData.add(RepeatsByGradeSeries(grade, 0.0));
      }
    }

    print(chartData);

    return [
      charts.Series<RepeatsByGradeSeries, String>(
        id: 'attemptsToSend',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
        domainFn: (RepeatsByGradeSeries attempts, _) => attempts.grade,
        measureFn: (RepeatsByGradeSeries attempts, _) => attempts.average,
        data: chartData,
      )
    ];
  }

  List<charts.TickSpec<String>> _buildTicks() {
    return widget.grades[filterGradeSet].map((grade) => charts.TickSpec(grade)).toList();
  }

  @override
  void dispose() {
    filteredAttemptsStream.close();
    if (filteredAttemptsListener != null) {
      filteredAttemptsListener.cancel();
    }
    gradeSetFilterStream.close();
    if (gradeSetFilterListener != null) {
      gradeSetFilterListener.cancel();
    }
    super.dispose();
  }
}

class RepeatsByGradeSeries {
  final String grade;
  final double average;

  @override
  String toString() {
    return "Series($grade, $average)";
  }

  RepeatsByGradeSeries(this.grade, this.average);
}
