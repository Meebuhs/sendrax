import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

import 'attempt_filter.dart';

class AttemptsByDayChart extends StatefulWidget {
  AttemptsByDayChart(
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
  _AttemptsByDayChartState createState() => _AttemptsByDayChartState();
}

class _AttemptsByDayChartState extends State<AttemptsByDayChart> {
  List<charts.TickSpec<String>> ticks;
  StreamController<List<Attempt>> filteredAttemptsStream;
  StreamSubscription<List<Attempt>> filteredAttemptsListener;
  List<charts.Series> chartSeries;

  @override
  void initState() {
    filteredAttemptsStream = StreamController<List<Attempt>>.broadcast();
    filteredAttemptsListener = filteredAttemptsStream.stream.listen((filteredAttempts) {
      setState(() {
        chartSeries = _buildChartSeries(context, filteredAttempts);
      });
    });
    chartSeries = _buildChartSeries(context, widget.attempts);
    ticks = _buildTicks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
        child: Column(children: [
          AttemptFilter(
            attempts: widget.attempts,
            categories: widget.categories,
            locationNamesToIds: widget.locationNamesToIds,
            filteredAttemptsStream: filteredAttemptsStream,
            enableFilters: [
              FilterType.gradeSet,
              FilterType.grade,
              FilterType.timeframe,
              FilterType.location,
              FilterType.category
            ],
            grades: widget.grades,
          ),
          _buildChart(context)
        ]));
  }

  Widget _buildChart(BuildContext context) {
    return Expanded(
        child: Container(
            padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.all(Radius.circular(UIConstants.CARD_BORDER_RADIUS))),
            child: (chartSeries != null)
                ? charts.BarChart(
                    chartSeries,
                    primaryMeasureAxis: charts.NumericAxisSpec(
                        renderSpec: charts.GridlineRendererSpec(
                      labelStyle: charts.TextStyleSpec(
                        fontSize: Theme.of(context).accentTextTheme.caption.fontSize.toInt(),
                        fontWeight: Theme.of(context).accentTextTheme.caption.fontWeight.toString(),
                        color: charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
                      ),
                      lineStyle: charts.LineStyleSpec(
                        color:
                            charts.ColorUtil.fromDartColor(Theme.of(context).dialogBackgroundColor),
                      ),
                    )),
                    domainAxis: charts.OrdinalAxisSpec(
                      renderSpec: charts.SmallTickRendererSpec(
                        lineStyle: charts.LineStyleSpec(
                          color: charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
                        ),
                        labelStyle: charts.TextStyleSpec(
                          fontSize: Theme.of(context).accentTextTheme.caption.fontSize.toInt(),
                          fontWeight:
                              Theme.of(context).accentTextTheme.caption.fontWeight.toString(),
                          color: charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
                        ),
                      ),
                      tickProviderSpec: charts.StaticOrdinalTickProviderSpec(ticks),
                    ),
                    barGroupingType: charts.BarGroupingType.stacked,
                    defaultInteractions: false,
                    behaviors: [
                      charts.SeriesLegend(
                        entryTextStyle: charts.TextStyleSpec(
                          fontSize: Theme.of(context).accentTextTheme.caption.fontSize.toInt(),
                          fontWeight:
                              Theme.of(context).accentTextTheme.caption.fontWeight.toString(),
                          color: charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                    "There are no existing attempts ${widget.attempts.isNotEmpty ? "matching these filters" : ""}. \nGo log some!",
                    style: Theme.of(context).accentTextTheme.subtitle2,
                    textAlign: TextAlign.center,
                  ))));
  }

  List<charts.Series<AttemptsByDaySeries, String>> _buildChartSeries(
      BuildContext context, List<Attempt> filteredAttempts) {
    if (filteredAttempts.isEmpty) {
      return null;
    }

    Map<String, Map<int, int>> dayCountsBySendType = <String, Map<int, int>>{};
    for (String sendType in SendTypes.SEND_TYPES) {
      dayCountsBySendType.putIfAbsent(
          sendType,
          () => Map.fromIterable(List<int>.generate(7, (i) => i),
              key: (item) => item, value: (item) => 0));
    }

    for (Attempt attempt in filteredAttempts) {
      int day = (attempt.timestamp.toDate().weekday + 6) % 7;
      dayCountsBySendType[attempt.sendType].update(day, (value) => value + 1);
    }

    Map<String, List<AttemptsByDaySeries>> chartDataMap = <String, List<AttemptsByDaySeries>>{};

    for (String sendType in SendTypes.SEND_TYPES) {
      chartDataMap.putIfAbsent(sendType, () => <AttemptsByDaySeries>[]);
      for (int day in dayCountsBySendType[sendType].keys) {
        chartDataMap[sendType].add(AttemptsByDaySeries(day, dayCountsBySendType[sendType][day]));
      }
    }

    List<charts.Series<AttemptsByDaySeries, String>> chartSeries =
        <charts.Series<AttemptsByDaySeries, String>>[];
    SendTypes.SEND_TYPES.asMap().forEach((index, sendType) {
      chartSeries.add(charts.Series<AttemptsByDaySeries, String>(
        id: sendType,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(SeriesConstants.COLOURS[index]),
        domainFn: (AttemptsByDaySeries attempts, _) => attempts.day.toString(),
        measureFn: (AttemptsByDaySeries attempts, _) => attempts.count,
        data: chartDataMap[sendType],
      ));
    });

    return chartSeries;
  }

  List<charts.TickSpec<String>> _buildTicks() {
    Map<int, String> weekdays = {
      0: "Mon",
      1: "Tue",
      2: "Wed",
      3: "Thu",
      4: "Fri",
      5: "Sat",
      6: "Sun"
    };

    List<charts.TickSpec<String>> ticks = [];

    for (int day in Iterable.generate(7)) {
      ticks.add(charts.TickSpec(day.toString(), label: weekdays[day]));
    }
    return ticks;
  }

  @override
  void dispose() {
    filteredAttemptsStream.close();
    if (filteredAttemptsListener != null) {
      filteredAttemptsListener.cancel();
    }
    super.dispose();
  }
}

class AttemptsByDaySeries {
  final int day;
  final int count;

  AttemptsByDaySeries(this.day, this.count);
}
