import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

class AttemptsByDateChart extends StatefulWidget {
  AttemptsByDateChart({Key key, @required this.attempts}) : super(key: key);
  final List<Attempt> attempts;

  @override
  _AttemptsByDateChartState createState() => _AttemptsByDateChartState();
}

class _AttemptsByDateChartState extends State<AttemptsByDateChart> {
  List<charts.Series> chartData;

  DateTime selectedDate;
  int selectedCount;

  @override
  void initState() {
    chartData = _buildChartData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];
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
              borderRadius: BorderRadius.all(Radius.circular(UIConstants.CARD_BORDER_RADIUS))
            ),
            child: charts.TimeSeriesChart(
              chartData,
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
                  fontWeight: Theme.of(context).accentTextTheme.caption.fontWeight.toString(),
                  color: charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
                ),
                lineStyle: charts.LineStyleSpec(
                  color: charts.ColorUtil.fromDartColor(Theme.of(context).dialogBackgroundColor),
                ),
              )),
              domainAxis: charts.DateTimeAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                labelStyle: charts.TextStyleSpec(
                  fontSize: Theme.of(context).accentTextTheme.caption.fontSize.toInt(),
                  fontWeight: Theme.of(context).accentTextTheme.caption.fontWeight.toString(),
                  color: charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
                ),
              )),
            )));
  }

  List<charts.Series<AttemptsByDateSeries, DateTime>> _buildChartData(BuildContext context) {
    List<AttemptsByDateSeries> chartData = <AttemptsByDateSeries>[];
    DateTime firstDate = widget.attempts[0].timestamp.toDate();
    DateTime currentDate = DateTime(firstDate.year, firstDate.month, firstDate.day);
    int currentCount = 1;

    for (Attempt attempt in widget.attempts.skip(1)) {
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
      new charts.Series<AttemptsByDateSeries, DateTime>(
        id: 'attemptsByDate',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
        domainFn: (AttemptsByDateSeries attempts, _) => attempts.date,
        measureFn: (AttemptsByDateSeries attempts, _) => attempts.count,
        data: chartData,
      )
    ];
  }

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    DateTime date;
    int count;

    if (selectedDatum.isNotEmpty) {
      date = selectedDatum.first.datum.date;
      count = selectedDatum[0].datum.count;
    }

    // Request a build.
    setState(() {
      selectedDate = date;
      selectedCount = count;
    });
  }
}

class AttemptsByDateSeries {
  final DateTime date;
  final int count;

  AttemptsByDateSeries(this.date, this.count);
}
