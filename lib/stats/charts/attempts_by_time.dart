import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

import 'attempt_filter.dart';

class AttemptsByTimeChart extends StatefulWidget {
  AttemptsByTimeChart({Key key, @required this.attempts, @required this.locationNamesToIds})
      : super(key: key);
  final Map<String, String> locationNamesToIds;
  final List<Attempt> attempts;

  @override
  _AttemptsByTimeChartState createState() => _AttemptsByTimeChartState();
}

class _AttemptsByTimeChartState extends State<AttemptsByTimeChart> {
  List<charts.TickSpec<String>> ticks;
  StreamController<List<Attempt>> filteredAttemptsStream;

  int selectedHour;
  int selectedCount;

  @override
  void initState() {
    filteredAttemptsStream = StreamController<List<Attempt>>.broadcast();
    ticks = _buildTicks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];
    children.add(AttemptFilter(
        attempts: widget.attempts,
        locationNamesToIds: widget.locationNamesToIds,
        filteredAttemptsStream: filteredAttemptsStream));
    children.add(_buildChart(context));
    DateTime time = DateTime.now();
    if (selectedHour != null) {
      children.add(Padding(
        padding: EdgeInsets.only(top: UIConstants.SMALLER_PADDING),
        child: _buildSelectedText(time),
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

  Widget _buildSelectedText(DateTime time) {
    String firstTime = DateFormat('h a').format(DateTime(time.year, time.month, time.day,
        selectedHour, time.minute, time.second, time.millisecond, time.microsecond));
    String secondTime = DateFormat('h a').format(DateTime(time.year, time.month, time.day,
        selectedHour + 1, time.minute, time.second, time.millisecond, time.microsecond));
    String rangeText = "$firstTime - $secondTime: $selectedCount";

    return Text(
      rangeText,
      style: Theme.of(context).accentTextTheme.subtitle2,
    );
  }

  Widget _buildChart(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.only(top: UIConstants.SMALLER_PADDING),
            child: Container(
                padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(UIConstants.CARD_BORDER_RADIUS))),
                child: StreamBuilder(
                    stream: filteredAttemptsStream.stream,
                    initialData: widget.attempts,
                    builder: (BuildContext context, snapshot) {
                      List<charts.Series> chartSeries = _buildChartSeries(context, snapshot.data);
                      return (chartSeries != null)
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
                                lineStyle: charts.LineStyleSpec(
                                  color: charts.ColorUtil.fromDartColor(
                                      Theme.of(context).dialogBackgroundColor),
                                ),
                              )),
                              domainAxis: charts.OrdinalAxisSpec(
                                renderSpec: charts.SmallTickRendererSpec(
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
                                tickProviderSpec: charts.StaticOrdinalTickProviderSpec(ticks),
                              ))
                          : Center(
                              child: Text(
                              "There are no existing attempts ${widget.attempts.isNotEmpty ? "matching these filters" : ""}. \nGo log some!",
                              style: Theme.of(context).accentTextTheme.subtitle2,
                              textAlign: TextAlign.center,
                            ));
                    }))));
  }

  List<charts.Series<AttemptsByTimeSeries, String>> _buildChartSeries(
      BuildContext context, List<Attempt> filteredAttempts) {
    _resetChartSelection();

    if (filteredAttempts.isEmpty) {
      return null;
    }

    List<AttemptsByTimeSeries> chartData = <AttemptsByTimeSeries>[];
    Map<int, int> hourCounts = Map.fromIterable(List<int>.generate(24, (i) => i + 1),
        key: (item) => item - 1, value: (item) => 0);

    for (Attempt attempt in filteredAttempts) {
      int attemptHour = attempt.timestamp.toDate().hour;
      hourCounts.update(attemptHour, (value) => hourCounts[attemptHour] + 1);
    }
    for (int hour in hourCounts.keys) {
      chartData.add(AttemptsByTimeSeries(hour, hourCounts[hour]));
    }

    return [
      charts.Series<AttemptsByTimeSeries, String>(
        id: 'attemptsByTime',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
        domainFn: (AttemptsByTimeSeries attempts, _) => attempts.hour.toString(),
        measureFn: (AttemptsByTimeSeries attempts, _) => attempts.count,
        data: chartData,
      )
    ];
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

  void _resetChartSelection() {
    if (selectedHour != null) {
      setState(() {
        selectedHour = null;
        selectedCount = null;
      });
    }
  }

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    int hour;
    int count;

    if (selectedDatum.isNotEmpty) {
      hour = selectedDatum.first.datum.hour;
      count = selectedDatum.first.datum.count;
    }

    // Request a build.
    setState(() {
      selectedHour = hour;
      selectedCount = count;
    });
  }

  @override
  void dispose() {
    filteredAttemptsStream.close();
    super.dispose();
  }
}

class AttemptsByTimeSeries {
  final int hour;
  final int count;

  AttemptsByTimeSeries(this.hour, this.count);
}
