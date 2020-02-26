import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

import 'attempt_filter.dart';

class AttemptsByTimeChart extends StatefulWidget {
  AttemptsByTimeChart(
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
  _AttemptsByTimeChartState createState() => _AttemptsByTimeChartState();
}

class _AttemptsByTimeChartState extends State<AttemptsByTimeChart> {
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

  List<charts.Series<AttemptsByTimeSeries, String>> _buildChartSeries(
      BuildContext context, List<Attempt> filteredAttempts) {
    if (filteredAttempts.isEmpty) {
      return null;
    }

    Map<String, Map<int, int>> hourCountsBySendType = <String, Map<int, int>>{};
    for (String sendType in SendTypes.SEND_TYPES) {
      hourCountsBySendType.putIfAbsent(
          sendType,
          () => Map.fromIterable(List<int>.generate(24, (i) => i + 1),
              key: (item) => item - 1, value: (item) => 0));
    }

    for (Attempt attempt in filteredAttempts) {
      int attemptHour = attempt.timestamp.toDate().hour;
      hourCountsBySendType[attempt.sendType].update(attemptHour, (value) => value + 1);
    }

    Map<String, List<AttemptsByTimeSeries>> chartDataMap = <String, List<AttemptsByTimeSeries>>{};

    for (String sendType in SendTypes.SEND_TYPES) {
      chartDataMap.putIfAbsent(sendType, () => <AttemptsByTimeSeries>[]);
      for (int hour in hourCountsBySendType[sendType].keys) {
        chartDataMap[sendType]
            .add(AttemptsByTimeSeries(hour, hourCountsBySendType[sendType][hour]));
      }
    }

    List<charts.Series<AttemptsByTimeSeries, String>> chartSeries =
        <charts.Series<AttemptsByTimeSeries, String>>[];
    SendTypes.SEND_TYPES.asMap().forEach((index, sendType) {
      chartSeries.add(charts.Series<AttemptsByTimeSeries, String>(
        id: sendType,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(SeriesConstants.COLOURS[index]),
        domainFn: (AttemptsByTimeSeries attempts, _) => attempts.hour.toString(),
        measureFn: (AttemptsByTimeSeries attempts, _) => attempts.count,
        data: chartDataMap[sendType],
      ));
    });

    return chartSeries;
  }

  List<charts.TickSpec<String>> _buildTicks() {
    DateTime time = DateTime.now();

    List<charts.TickSpec<String>> ticks = [];

    for (int hour in Iterable.generate(24)) {
      if (hour % 6 == 0) {
        ticks.add(charts.TickSpec(
          hour.toString(),
          label:
              "${DateFormat('h a').format(DateTime(time.year, time.month, time.day, hour, time.minute, time.second, time.millisecond, time.microsecond))}",
        ));
      } else {
        ticks.add(charts.TickSpec(
          hour.toString(),
          label: "",
        ));
      }
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

class AttemptsByTimeSeries {
  final int hour;
  final int count;

  AttemptsByTimeSeries(this.hour, this.count);
}
