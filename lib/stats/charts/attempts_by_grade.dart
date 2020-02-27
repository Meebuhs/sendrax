import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

import 'attempt_filter.dart';

class AttemptsByGradeChart extends StatefulWidget {
  AttemptsByGradeChart(
      {Key key,
        @required this.attempts,
        @required this.categories,
        @required this.grades,
        @required this.locationNamesToIds,
        @required this.locationNamesToGradeSet})
      : super(key: key);
  final List<Attempt> attempts;
  final List<String> categories;
  final Map<String, List<String>> grades;
  final Map<String, String> locationNamesToIds;
  final Map<String, String> locationNamesToGradeSet;

  @override
  _AttemptsByGradeChartState createState() => _AttemptsByGradeChartState();
}

class _AttemptsByGradeChartState extends State<AttemptsByGradeChart> {
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
            locationNamesToGradeSet: widget.locationNamesToGradeSet,
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
          behaviors: [
            charts.SeriesLegend(
              entryTextStyle: charts.TextStyleSpec(
                fontSize: Theme.of(context).accentTextTheme.caption.fontSize.toInt(),
                fontWeight: Theme.of(context).accentTextTheme.caption.fontWeight.toString(),
                color: charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
              ),
            ),
          ],
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

  List<charts.Series<AttemptsByGradeSeries, String>> _buildChartSeries(
      BuildContext context, List<Attempt> filteredAttempts) {
    if (filteredAttempts.isEmpty) {
      return null;
    }

    Map<String, Map<String, int>> attemptsBySendType = <String, Map<String, int>>{};
    for (String sendType in SendTypes.SEND_TYPES) {
      attemptsBySendType.putIfAbsent(
          sendType,
          () => Map.fromIterable(widget.grades[filterGradeSet],
              key: (item) => item, value: (item) => 0));
    }

    for (Attempt attempt in filteredAttempts) {
      String grade = attempt.climbGrade;
      attemptsBySendType[attempt.sendType].update(grade, (count) => count + 1);
    }

    Map<String, List<AttemptsByGradeSeries>> chartDataMap = <String, List<AttemptsByGradeSeries>>{};

    for (String sendType in SendTypes.SEND_TYPES) {
      chartDataMap.putIfAbsent(sendType, () => <AttemptsByGradeSeries>[]);
      for (String grade in attemptsBySendType[sendType].keys) {
        chartDataMap[sendType].add(AttemptsByGradeSeries(grade, attemptsBySendType[sendType][grade]));
      }
    }

    List<charts.Series<AttemptsByGradeSeries, String>> chartSeries =
        <charts.Series<AttemptsByGradeSeries, String>>[];
    SendTypes.SEND_TYPES.asMap().forEach((index, sendType) {
      chartSeries.add(charts.Series<AttemptsByGradeSeries, String>(
        id: sendType,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(SeriesConstants.COLOURS[index]),
        domainFn: (AttemptsByGradeSeries attempts, _) => attempts.grade,
        measureFn: (AttemptsByGradeSeries attempts, _) => attempts.count,
        data: chartDataMap[sendType],
      ));
    });

    return chartSeries;
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

class AttemptsByGradeSeries {
  final String grade;
  final int count;

  AttemptsByGradeSeries(this.grade, this.count);
}
