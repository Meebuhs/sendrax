import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/stats/charts/attempt_filter.dart';
import 'package:sendrax/util/constants.dart';

class AttemptsByValueChart extends StatefulWidget {
  AttemptsByValueChart(
      {Key key,
      @required this.attempts,
      @required this.categories,
      @required this.grades,
      @required this.locationNamesToIds,
      @required this.locationNamesToGradeSet,
      @required this.buildTicks,
      @required this.processAttempt,
      @required this.createEmptyMap,
      @required this.enableFilters,
      this.rotateLabels})
      : super(key: key);
  final List<Attempt> attempts;
  final List<String> categories;
  final Map<String, List<String>> grades;
  final Map<String, String> locationNamesToIds;
  final Map<String, String> locationNamesToGradeSet;
  final Function() buildTicks;
  final Function(Attempt) processAttempt;
  final Function() createEmptyMap;
  final List<FilterType> enableFilters;
  final bool rotateLabels;

  @override
  _AttemptsByValueChartState createState() => _AttemptsByValueChartState();
}

class _AttemptsByValueChartState extends State<AttemptsByValueChart> {
  List<charts.TickSpec<String>> ticks;
  StreamController<List<Attempt>> filteredAttemptsStream;
  StreamSubscription<List<Attempt>> filteredAttemptsListener;
  List<charts.Series> chartSeries;

  @override
  void initState() {
    filteredAttemptsStream = StreamController<List<Attempt>>.broadcast();
    filteredAttemptsListener =
        filteredAttemptsStream.stream.listen((filteredAttempts) {
      setState(() {
        chartSeries = _buildChartSeries(context, filteredAttempts);
      });
    });
    chartSeries = _buildChartSeries(context, widget.attempts);
    ticks = widget.buildTicks();
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
            locationNamesToGradeSet: widget.locationNamesToGradeSet,
            filteredAttemptsStream: filteredAttemptsStream,
            enableFilters: widget.enableFilters,
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
                borderRadius: BorderRadius.all(
                    Radius.circular(UIConstants.CARD_BORDER_RADIUS))),
            child: (chartSeries != null)
                ? charts.BarChart(
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
                    )),
                    domainAxis: charts.OrdinalAxisSpec(
                      renderSpec: charts.SmallTickRendererSpec(
                        lineStyle: charts.LineStyleSpec(
                          color: charts.ColorUtil.fromDartColor(
                              Theme.of(context).accentColor),
                        ),
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
                        labelRotation: widget.rotateLabels ?? false ? 45 : 0,
                      ),
                      tickProviderSpec:
                          charts.StaticOrdinalTickProviderSpec(ticks),
                    ),
                    barGroupingType: charts.BarGroupingType.stacked,
                    defaultInteractions: false,
                    behaviors: [
                      charts.SeriesLegend(
                        entryTextStyle: charts.TextStyleSpec(
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
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                    "There are no existing attempts${widget.attempts.isNotEmpty ? " matching these filters" : ""}. \nGo log some!",
                    style: Theme.of(context).accentTextTheme.subtitle2,
                    textAlign: TextAlign.center,
                  ))));
  }

  List<charts.Series<AttemptsByValueSeries, String>> _buildChartSeries(
      BuildContext context, List<Attempt> filteredAttempts) {
    if (filteredAttempts.isEmpty) {
      return null;
    }

    Map<String, Map<String, int>> valuesBySendType =
        <String, Map<String, int>>{};
    for (String sendType in SendTypes.SEND_TYPES) {
      valuesBySendType.putIfAbsent(sendType, widget.createEmptyMap);
    }

    for (Attempt attempt in filteredAttempts) {
      List<String> values = widget.processAttempt(attempt);
      for (String value in values) {
        valuesBySendType[attempt.sendType].update(value, (count) => count + 1);
      }
    }

    Map<String, List<AttemptsByValueSeries>> chartDataMap =
        <String, List<AttemptsByValueSeries>>{};

    for (String sendType in SendTypes.SEND_TYPES) {
      chartDataMap.putIfAbsent(sendType, () => <AttemptsByValueSeries>[]);
      for (String value in valuesBySendType[sendType].keys) {
        chartDataMap[sendType].add(
            AttemptsByValueSeries(value, valuesBySendType[sendType][value]));
      }
    }

    List<charts.Series<AttemptsByValueSeries, String>> chartSeries =
        <charts.Series<AttemptsByValueSeries, String>>[];
    SendTypes.SEND_TYPES.asMap().forEach((index, sendType) {
      chartSeries.add(charts.Series<AttemptsByValueSeries, String>(
        id: sendType,
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(SeriesConstants.COLOURS[index]),
        domainFn: (AttemptsByValueSeries attempts, _) => attempts.value,
        measureFn: (AttemptsByValueSeries attempts, _) => attempts.count,
        data: chartDataMap[sendType],
      ));
    });

    return chartSeries;
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

class AttemptsByValueSeries {
  final String value;
  final int count;

  AttemptsByValueSeries(this.value, this.count);
}
