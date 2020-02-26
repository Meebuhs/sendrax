import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

import 'attempt_filter.dart';

class AttemptsByDateChart extends StatefulWidget {
  AttemptsByDateChart(
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
  _AttemptsByDateChartState createState() => _AttemptsByDateChartState();
}

class _AttemptsByDateChartState extends State<AttemptsByDateChart> {
  StreamController<List<Attempt>> filteredAttemptsStream;
  StreamSubscription<List<Attempt>> filteredAttemptsListener;
  List<charts.Series> chartSeries;
  DateTime selectedDate;
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
    if (selectedDate != null) {
      children.add(Padding(
          padding: EdgeInsets.only(top: UIConstants.SMALLER_PADDING),
          child: Text(
            "${DateFormat('MMM d, y').format(selectedDate)}: $selectedCount",
            style: Theme.of(context).accentTextTheme.subtitle2,
          )));
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
                ? charts.TimeSeriesChart(
                    chartSeries,
                    dateTimeFactory: charts.LocalDateTimeFactory(),
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
                            fontWeight:
                                Theme.of(context).accentTextTheme.caption.fontWeight.toString(),
                            color: charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
                          ),
                          lineStyle: charts.LineStyleSpec(
                            color: charts.ColorUtil.fromDartColor(
                                Theme.of(context).dialogBackgroundColor),
                          ),
                        ),
                        tickProviderSpec:
                        charts.BasicNumericTickProviderSpec(desiredTickCount: 6)),
                    domainAxis: charts.DateTimeAxisSpec(
                        renderSpec: charts.SmallTickRendererSpec(
                      lineStyle: charts.LineStyleSpec(
                        color: charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
                      ),
                      labelStyle: charts.TextStyleSpec(
                        fontSize: Theme.of(context).accentTextTheme.caption.fontSize.toInt(),
                        fontWeight: Theme.of(context).accentTextTheme.caption.fontWeight.toString(),
                        color: charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
                      ),
                    )),
                  )
                : Center(
                    child: Text(
                    "There are no existing attempts ${widget.attempts.isNotEmpty ? "matching these filters" : ""}. \nGo log some!",
                    style: Theme.of(context).accentTextTheme.subtitle2,
                    textAlign: TextAlign.center,
                  ))));
  }

  List<charts.Series<AttemptsByDateSeries, DateTime>> _buildChartSeries(
      BuildContext context, List<Attempt> filteredAttempts) {
    _resetChartSelection();

    if (filteredAttempts.isEmpty) {
      return null;
    }

    List<AttemptsByDateSeries> chartData = <AttemptsByDateSeries>[];
    DateTime firstDate = filteredAttempts.first.timestamp.toDate();
    DateTime currentDate = DateTime(firstDate.year, firstDate.month, firstDate.day);
    int currentCount = 1;

    for (Attempt attempt in filteredAttempts.skip(1)) {
      DateTime attemptDate = attempt.timestamp.toDate();
      DateTime startOfDay = DateTime(attemptDate.year, attemptDate.month, attemptDate.day);
      if (currentDate != startOfDay) {
        chartData.add(AttemptsByDateSeries(currentDate, currentCount));
        currentDate = startOfDay;
        currentCount = 1;
      } else {
        currentCount++;
      }
    }
    chartData.add(AttemptsByDateSeries(currentDate, currentCount));

    return [
      charts.Series<AttemptsByDateSeries, DateTime>(
        id: 'attemptsByDate',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
        domainFn: (AttemptsByDateSeries attempts, _) => attempts.date,
        measureFn: (AttemptsByDateSeries attempts, _) => attempts.count,
        data: chartData,
      )
    ];
  }

  void _resetChartSelection() {
    if (selectedDate != null) {
      setState(() {
        selectedDate = null;
        selectedCount = null;
      });
    }
  }

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    DateTime date;
    int count;

    if (selectedDatum.isNotEmpty) {
      date = selectedDatum.first.datum.date;
      count = selectedDatum.first.datum.count;
    }

    // Request a build.
    setState(() {
      selectedDate = date;
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

class AttemptsByDateSeries {
  final DateTime date;
  final int count;

  AttemptsByDateSeries(this.date, this.count);
}
