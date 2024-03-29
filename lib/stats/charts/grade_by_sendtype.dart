import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

import 'attempt_filter.dart';

class GradeBySendTypeChart extends StatefulWidget {
  GradeBySendTypeChart(
      {Key key,
      @required this.attempts,
      @required this.categories,
      @required this.grades,
      @required this.locationNamesToGradeSet,
      @required this.locationNamesToIds,
      @required this.average})
      : super(key: key);
  final List<Attempt> attempts;
  final List<String> categories;
  final Map<String, List<String>> grades;
  final Map<String, String> locationNamesToIds;
  final Map<String, String> locationNamesToGradeSet;
  final bool average;

  @override
  _GradeBySendTypeChartState createState() => _GradeBySendTypeChartState();
}

class _GradeBySendTypeChartState extends State<GradeBySendTypeChart> {
  StreamController<List<Attempt>> filteredAttemptsStream;
  StreamSubscription<List<Attempt>> filteredAttemptsListener;
  StreamController<String> gradeSetFilterStream;
  StreamSubscription<String> gradeSetFilterListener;
  String filterGradeSet;
  List<charts.Series> chartSeries;

  @override
  void initState() {
    filteredAttemptsStream = StreamController<List<Attempt>>.broadcast();
    filteredAttemptsListener =
        filteredAttemptsStream.stream.listen((filteredAttempts) {
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
              FilterType.location
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
        content = charts.TimeSeriesChart(
          chartSeries,
          dateTimeFactory: charts.LocalDateTimeFactory(),
          primaryMeasureAxis: charts.NumericAxisSpec(
            renderSpec: charts.GridlineRendererSpec(
                labelStyle: charts.TextStyleSpec(
                  fontSize: Theme.of(context)
                      .accentTextTheme
                      .caption
                      .fontSize
                      .toInt(),
                  fontWeight: Theme.of(context)
                      .accentTextTheme
                      .caption
                      .fontWeight
                      .toString(),
                  color: charts.ColorUtil.fromDartColor(
                      Theme.of(context).accentColor),
                ),
                lineStyle: charts.LineStyleSpec(
                  color: charts.ColorUtil.fromDartColor(
                      Theme.of(context).dialogBackgroundColor),
                )),
            tickProviderSpec:
                charts.StaticNumericTickProviderSpec(_buildTicks()),
          ),
          domainAxis: charts.DateTimeAxisSpec(
              renderSpec: charts.SmallTickRendererSpec(
            lineStyle: charts.LineStyleSpec(
              color:
                  charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
            ),
            labelStyle: charts.TextStyleSpec(
              fontSize:
                  Theme.of(context).accentTextTheme.caption.fontSize.toInt(),
              fontWeight: Theme.of(context)
                  .accentTextTheme
                  .caption
                  .fontWeight
                  .toString(),
              color:
                  charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
            ),
          )),
          behaviors: [
            charts.SeriesLegend(
              entryTextStyle: charts.TextStyleSpec(
                fontSize:
                    Theme.of(context).accentTextTheme.caption.fontSize.toInt(),
                fontWeight: Theme.of(context)
                    .accentTextTheme
                    .caption
                    .fontWeight
                    .toString(),
                color: charts.ColorUtil.fromDartColor(
                    Theme.of(context).accentColor),
              ),
            ),
          ],
        );
      } else {
        content = Center(
            child: Text(
          "There are no existing attempts${widget.attempts.isNotEmpty ? " matching these filters" : ""}. \nGo log some!",
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
                borderRadius: BorderRadius.all(
                    Radius.circular(UIConstants.CARD_BORDER_RADIUS))),
            child: content));
  }

  List<charts.Series<AttemptsByDateSeries, DateTime>> _buildChartSeries(
      BuildContext context, List<Attempt> filteredAttempts) {
    if (filteredAttempts.isEmpty) {
      return null;
    }

    Map<String, List<AttemptsByDateSeries>> chartDataMap =
        <String, List<AttemptsByDateSeries>>{};
    DateTime firstDate = filteredAttempts.first.timestamp.toDate();
    DateTime currentDate =
        DateTime(firstDate.year, firstDate.month, firstDate.day);

    Map<String, int> gradeToValueMap = <String, int>{};
    int counter = 1;
    for (String grade in widget.grades[filterGradeSet]) {
      gradeToValueMap.putIfAbsent(grade, () => counter);
      counter++;
    }

    for (String sendType in SendTypes.SEND_TYPES) {
      chartDataMap.putIfAbsent(sendType, () => <AttemptsByDateSeries>[]);
    }

    Map<String, List<int>> sendTypeToGradesAttempted = Map.fromIterable(
        SendTypes.SEND_TYPES,
        key: (item) => item,
        value: (item) => <int>[]);
    sendTypeToGradesAttempted.update(
        filteredAttempts.first.sendType,
        (value) =>
            value..add(gradeToValueMap[filteredAttempts.first.climbGrade]));

    for (Attempt attempt in filteredAttempts.skip(1)) {
      DateTime attemptDate = attempt.timestamp.toDate();
      DateTime startOfDay =
          DateTime(attemptDate.year, attemptDate.month, attemptDate.day);

      if (currentDate != startOfDay) {
        chartDataMap = _updateChartData(
            currentDate, sendTypeToGradesAttempted, chartDataMap);
        currentDate = startOfDay;
        sendTypeToGradesAttempted = Map.fromIterable(SendTypes.SEND_TYPES,
            key: (item) => item, value: (item) => <int>[]);
      }
      sendTypeToGradesAttempted.update(attempt.sendType,
          (value) => value..add(gradeToValueMap[attempt.climbGrade]));
    }
    chartDataMap =
        _updateChartData(currentDate, sendTypeToGradesAttempted, chartDataMap);

    List<charts.Series<AttemptsByDateSeries, DateTime>> chartSeries =
        <charts.Series<AttemptsByDateSeries, DateTime>>[];
    SendTypes.SEND_TYPES.asMap().forEach((index, sendType) {
      chartSeries.add(charts.Series<AttemptsByDateSeries, DateTime>(
        id: sendType,
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(SeriesConstants.COLOURS[index]),
        domainFn: (AttemptsByDateSeries attempts, _) => attempts.date,
        measureFn: (AttemptsByDateSeries attempts, _) => attempts.gradeValue,
        data: chartDataMap[sendType],
      ));
    });

    return chartSeries;
  }

  Map<String, List<AttemptsByDateSeries>> _updateChartData(
      DateTime currentDate,
      Map<String, List<int>> sendTypeToGradesAttempted,
      Map<String, List<AttemptsByDateSeries>> chartDataMap) {
    for (String sendType in SendTypes.SEND_TYPES) {
      if (sendTypeToGradesAttempted[sendType].isNotEmpty) {
        chartDataMap.update(sendType, (value) {
          if (widget.average) {
            return value
              ..add(AttemptsByDateSeries(
                  currentDate,
                  sendTypeToGradesAttempted[sendType].reduce((a, b) => a + b) /
                      sendTypeToGradesAttempted[sendType].length));
          } else {
            return value
              ..add(AttemptsByDateSeries(
                  currentDate,
                  sendTypeToGradesAttempted[sendType]
                      .reduce((a, b) => a > b ? a : b)
                      .toDouble()));
          }
        });
      }
    }
    return chartDataMap;
  }

  List<charts.TickSpec<double>> _buildTicks() {
    List<charts.TickSpec<double>> ticks = [
      charts.TickSpec(
        0,
        label: "",
      )
    ];

    for (int gradeValue
        in Iterable.generate(widget.grades[filterGradeSet].length)) {
      ticks.add(charts.TickSpec(
        gradeValue.toDouble() + 1,
        label: widget.grades[filterGradeSet][gradeValue],
      ));
    }
    return ticks;
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

class AttemptsByDateSeries {
  final DateTime date;
  final double gradeValue;

  @override
  String toString() {
    return "Series(${DateFormat('MMM d, y').format(date)}, $gradeValue)";
  }

  AttemptsByDateSeries(this.date, this.gradeValue);
}
