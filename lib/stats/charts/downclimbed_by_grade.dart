import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

import 'attempt_filter.dart';

class DownclimbedByGradeChart extends StatefulWidget {
  DownclimbedByGradeChart(
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
  _DownclimbedByGradeChartState createState() =>
      _DownclimbedByGradeChartState();
}

class _DownclimbedByGradeChartState extends State<DownclimbedByGradeChart> {
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
                ),
              ),
              tickProviderSpec:
                  charts.StaticNumericTickProviderSpec(_buildMeasureTicks()),
              tickFormatterSpec:
                  charts.BasicNumericTickFormatterSpec.fromNumberFormat(
                      NumberFormat.percentPattern())),
          domainAxis: charts.OrdinalAxisSpec(
            renderSpec: charts.SmallTickRendererSpec(
              lineStyle: charts.LineStyleSpec(
                color: charts.ColorUtil.fromDartColor(
                    Theme.of(context).accentColor),
              ),
              labelStyle: charts.TextStyleSpec(
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
            tickProviderSpec:
                charts.StaticOrdinalTickProviderSpec(_buildDomainTicks()),
          ),
          barGroupingType: charts.BarGroupingType.grouped,
          defaultInteractions: false,
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

  List<charts.Series<DownclimbedByGradeSeries, String>> _buildChartSeries(
      BuildContext context, List<Attempt> filteredAttempts) {
    if (filteredAttempts.isEmpty) {
      return null;
    }

    List<String> sendTypes = List.from(SendTypes.SEND_TYPES)..removeLast();

    Map<String, Map<String, List<int>>> attemptsBySendType =
        <String, Map<String, List<int>>>{};
    for (String sendType in sendTypes) {
      attemptsBySendType.putIfAbsent(
          sendType,
          () => Map.fromIterable(widget.grades[filterGradeSet],
              key: (item) => item, value: (item) => [0, 0]));
    }

    for (Attempt attempt in filteredAttempts) {
      String grade = attempt.climbGrade;
      if (attempt.sendType != "Attempt") {
        attemptsBySendType[attempt.sendType].update(
            grade,
            (counts) =>
                [counts[0] + (attempt.downclimbed ? 1 : 0), counts[1] + 1]);
      }
    }

    Map<String, List<DownclimbedByGradeSeries>> chartDataMap =
        <String, List<DownclimbedByGradeSeries>>{};

    for (String sendType in sendTypes) {
      chartDataMap.putIfAbsent(sendType, () => <DownclimbedByGradeSeries>[]);
      for (String grade in attemptsBySendType[sendType].keys) {
        chartDataMap[sendType].add(DownclimbedByGradeSeries(
          grade,
          attemptsBySendType[sendType][grade][0],
          attemptsBySendType[sendType][grade][1],
        ));
      }
    }

    List<charts.Series<DownclimbedByGradeSeries, String>> chartSeries =
        <charts.Series<DownclimbedByGradeSeries, String>>[];
    sendTypes.asMap().forEach((index, sendType) {
      chartSeries.add(charts.Series<DownclimbedByGradeSeries, String>(
        id: sendType,
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(SeriesConstants.COLOURS[index]),
        domainFn: (DownclimbedByGradeSeries attempts, _) => attempts.grade,
        measureFn: (DownclimbedByGradeSeries attempts, _) =>
            (attempts.count == 0) ? 0.0 : attempts.downclimbed / attempts.count,
        data: chartDataMap[sendType],
      ));
    });

    return chartSeries;
  }

  List<charts.TickSpec<num>> _buildMeasureTicks() {
    List<charts.TickSpec<num>> ticks = [];
    for (int value in List.generate(6, (index) => index)) {
      ticks.add(charts.TickSpec<num>(value * 0.2,
          label: NumberFormat.percentPattern().format(value * 0.2)));
    }
    return ticks;
  }

  List<charts.TickSpec<String>> _buildDomainTicks() {
    return widget.grades[filterGradeSet]
        .map((grade) => charts.TickSpec(grade))
        .toList();
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

class DownclimbedByGradeSeries {
  final String grade;
  final int downclimbed;
  final int count;

  DownclimbedByGradeSeries(this.grade, this.downclimbed, this.count);
}
