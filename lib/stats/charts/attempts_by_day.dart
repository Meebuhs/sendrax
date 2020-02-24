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
  Map<int, String> weekdays = {
    0: "Mon",
    1: "Tue",
    2: "Wed",
    3: "Thu",
    4: "Fri",
    5: "Sat",
    6: "Sun"
  };

  int selectedDay;
  int selectedCount;

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
    List<Widget> children = <Widget>[];
    children.add(AttemptFilter(
      attempts: widget.attempts,
      categories: widget.categories,
      locationNamesToIds: widget.locationNamesToIds,
      filteredAttemptsStream: filteredAttemptsStream,
      grades: widget.grades,
    ));
    children.add(_buildChart(context));
    if (selectedDay != null) {
      children.add(Padding(
        padding: EdgeInsets.only(top: UIConstants.SMALLER_PADDING),
        child: Text(
          "${weekdays[selectedDay]}: $selectedCount",
          style: Theme.of(context).accentTextTheme.subtitle2,
        ),
      ));
    } else {
      children.add(Padding(
          padding: EdgeInsets.only(top: UIConstants.SMALLER_PADDING),
          child: Text(
            " ",
            style: Theme.of(context).accentTextTheme.subtitle2,
          )));
    }
    return Padding(
        padding: EdgeInsets.all(UIConstants.SMALLER_PADDING), child: Column(children: children));
  }

  Widget _buildChart(BuildContext context) {
    return Expanded(
        child: Container(
            padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.all(Radius.circular(UIConstants.CARD_BORDER_RADIUS))),
            child: (chartSeries != null)
                ? charts.BarChart(chartSeries,
                    selectionModels: [
                      charts.SelectionModelConfig(
                        type: charts.SelectionModelType.info,
                        changedListener: _onSelectionChanged,
                      )
                    ],
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
                    ))
                : Center(
                    child: Text(
                    "There are no existing attempts ${widget.attempts.isNotEmpty ? "matching these filters" : ""}. \nGo log some!",
                    style: Theme.of(context).accentTextTheme.subtitle2,
                    textAlign: TextAlign.center,
                  ))));
  }

  List<charts.Series<AttemptsByTimeSeries, String>> _buildChartSeries(
      BuildContext context, List<Attempt> filteredAttempts) {
    _resetChartSelection();

    if (filteredAttempts.isEmpty) {
      return null;
    }

    List<AttemptsByTimeSeries> chartData = <AttemptsByTimeSeries>[];
    Map<int, int> dayCounts =
        Map.fromIterable(List<int>.generate(7, (i) => i), key: (item) => item, value: (item) => 0);

    for (Attempt attempt in filteredAttempts) {
      int day = (attempt.timestamp.toDate().weekday + 6) % 7;
      dayCounts.update(day, (value) => dayCounts[day] + 1);
    }
    for (int hour in dayCounts.keys) {
      chartData.add(AttemptsByTimeSeries(hour, dayCounts[hour]));
    }

    return [
      charts.Series<AttemptsByTimeSeries, String>(
        id: 'attemptsByTime',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
        domainFn: (AttemptsByTimeSeries attempts, _) => attempts.day.toString(),
        measureFn: (AttemptsByTimeSeries attempts, _) => attempts.count,
        data: chartData,
      )
    ];
  }

  List<charts.TickSpec<String>> _buildTicks() {
    List<charts.TickSpec<String>> ticks = [];

    for (int day in Iterable.generate(7)) {
      ticks.add(charts.TickSpec(day.toString(), label: weekdays[day]));
    }
    return ticks;
  }

  void _resetChartSelection() {
    if (selectedDay != null) {
      setState(() {
        selectedDay = null;
        selectedCount = null;
      });
    }
  }

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    int hour;
    int count;

    if (selectedDatum.isNotEmpty) {
      hour = selectedDatum.first.datum.day;
      count = selectedDatum.first.datum.count;
    }

    // Request a build.
    setState(() {
      selectedDay = hour;
      selectedCount = count;
    });
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
  final int day;
  final int count;

  AttemptsByTimeSeries(this.day, this.count);
}
