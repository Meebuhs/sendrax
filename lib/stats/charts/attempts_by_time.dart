import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

class AttemptsByTimeChart extends StatefulWidget {
  AttemptsByTimeChart({Key key, @required this.attempts, @required this.locationNamesToIds})
      : super(key: key);
  final Map<String, String> locationNamesToIds;
  final List<Attempt> attempts;

  @override
  _AttemptsByTimeChartState createState() => _AttemptsByTimeChartState();
}

class _AttemptsByTimeChartState extends State<AttemptsByTimeChart> {
  List<charts.Series> chartSeries;
  List<charts.TickSpec<String>> ticks;
  String filterTimeframe;
  String filterLocation;
  String filterSendType;
  String filterCategory;

  int selectedHour;
  int selectedCount;

  @override
  void initState() {
    chartSeries = _buildChartSeries(context);
    ticks = _buildTicks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];
    children.add(_buildFilters(context));
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

  Widget _buildFilters(BuildContext context) {
    return Container(
        child: Row(children: <Widget>[
      Expanded(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              _showTimeFrameDropdown(context),
              _showLocationDropdown(context),
            ],
          ),
          Row(
            children: <Widget>[
              _showSendTypeDropdown(context),
              _showCategoryDropdown(context),
            ],
          )
        ],
      )),
      _showClearDropdownsButton(context),
    ]));
  }

  Widget _showTimeFrameDropdown(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.fromLTRB(
                0.0, 0.0, UIConstants.SMALLER_PADDING / 2, UIConstants.SMALLER_PADDING / 2),
            child: Container(
                padding: EdgeInsets.all(UIConstants.STANDARD_PADDING),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(UIConstants.BUTTON_BORDER_RADIUS))),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                  style: Theme.of(context).accentTextTheme.subtitle2,
                  items: _createDropdownItems(TimeFrames.TIME_FRAMES.values.toList()),
                  value: filterTimeframe,
                  hint: Text("Time frame"),
                  isExpanded: true,
                  isDense: true,
                  onChanged: (value) => setState(() {
                    filterTimeframe = value;
                    chartSeries = _buildChartSeries(context);
                  }),
                )))));
  }

  Widget _showLocationDropdown(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.fromLTRB(
                UIConstants.SMALLER_PADDING / 2, 0.0, 0.0, UIConstants.SMALLER_PADDING / 2),
            child: Container(
                padding: EdgeInsets.all(UIConstants.STANDARD_PADDING),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(UIConstants.BUTTON_BORDER_RADIUS))),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                  style: Theme.of(context).accentTextTheme.subtitle2,
                  items: _createDropdownItems(widget.locationNamesToIds.keys.toList()),
                  value: filterLocation,
                  hint: Text("Location"),
                  isExpanded: true,
                  isDense: true,
                  onChanged: (value) => setState(() {
                    filterLocation = value;
                    chartSeries = _buildChartSeries(context);
                  }),
                )))));
  }

  Widget _showSendTypeDropdown(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.fromLTRB(
                0.0, UIConstants.SMALLER_PADDING / 2, UIConstants.SMALLER_PADDING / 2, 0.0),
            child: Container(
                padding: EdgeInsets.all(UIConstants.STANDARD_PADDING),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(UIConstants.BUTTON_BORDER_RADIUS))),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                  style: Theme.of(context).accentTextTheme.subtitle2,
                  items: _createDropdownItems(SendTypes.SEND_TYPES),
                  value: filterSendType,
                  hint: Text("Send type"),
                  isExpanded: true,
                  isDense: true,
                  onChanged: (value) => setState(() {
                    filterSendType = value;
                    chartSeries = _buildChartSeries(context);
                  }),
                )))));
  }

  Widget _showCategoryDropdown(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.fromLTRB(
                UIConstants.SMALLER_PADDING / 2, UIConstants.SMALLER_PADDING / 2, 0.0, 0.0),
            child: Container(
                padding: EdgeInsets.all(UIConstants.STANDARD_PADDING),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(UIConstants.BUTTON_BORDER_RADIUS))),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                  style: Theme.of(context).accentTextTheme.subtitle2,
                  items: _createDropdownItems(ClimbCategories.CATEGORIES),
                  value: filterCategory,
                  hint: Text("Category"),
                  isExpanded: true,
                  isDense: true,
                  onChanged: (value) => setState(() {
                    filterCategory = value;
                    chartSeries = _buildChartSeries(context);
                  }),
                )))));
  }

  Widget _showClearDropdownsButton(BuildContext context) {
    return Container(
        child: IconButton(
            icon: Icon(Icons.cancel,
                color: (filterTimeframe == null &&
                        filterLocation == null &&
                        filterSendType == null &&
                        filterCategory == null)
                    ? Colors.grey
                    : Theme.of(context).accentColor),
            onPressed: () => setState(() {
                  filterTimeframe = null;
                  filterLocation = null;
                  filterSendType = null;
                  filterCategory = null;
                  chartSeries = _buildChartSeries(context);
                })));
  }

  List<DropdownMenuItem> _createDropdownItems(List<String> items) {
    if (items.isNotEmpty) {
      return items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList();
    } else {
      // null disables the dropdown
      return null;
    }
  }

  Widget _buildChart(BuildContext context) {
    Widget chart = (chartSeries != null)
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
                color: charts.ColorUtil.fromDartColor(Theme.of(context).dialogBackgroundColor),
              ),
            )),
            domainAxis: charts.OrdinalAxisSpec(
              renderSpec: charts.SmallTickRendererSpec(
                labelStyle: charts.TextStyleSpec(
                  fontSize: Theme.of(context).accentTextTheme.caption.fontSize.toInt(),
                  fontWeight: Theme.of(context).accentTextTheme.caption.fontWeight.toString(),
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
          ));
    return Expanded(
        child: Padding(
            padding: EdgeInsets.only(top: UIConstants.SMALLER_PADDING),
            child: Container(
                padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(UIConstants.CARD_BORDER_RADIUS))),
                child: chart)));
  }

  List<charts.Series<AttemptsByTimeSeries, String>> _buildChartSeries(BuildContext context) {
    _resetChartSelection();
    List<Attempt> filteredAttempts = _filterAttempts();

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
    setState(() {
      selectedHour = null;
      selectedCount = null;
    });
  }

  List<Attempt> _filterAttempts() {
    List<Attempt> filteredAttempts = widget.attempts;

    if (filterTimeframe != null) {
      if (filterTimeframe == TimeFrames.TIME_FRAMES["lastWeek"]) {
        filteredAttempts = filteredAttempts
            .where((attempt) =>
                DateTime.now().difference(attempt.timestamp.toDate()) < Duration(days: 7))
            .toList();
      } else if (filterTimeframe == TimeFrames.TIME_FRAMES["lastMonth"]) {
        filteredAttempts = filteredAttempts
            .where((attempt) =>
                DateTime.now().difference(attempt.timestamp.toDate()) < Duration(days: 30))
            .toList();
      } else if (filterTimeframe == TimeFrames.TIME_FRAMES["lastYear"]) {
        filteredAttempts = filteredAttempts
            .where((attempt) =>
                DateTime.now().difference(attempt.timestamp.toDate()) < Duration(days: 365))
            .toList();
      }
    }
    if (filterLocation != null) {
      filteredAttempts = filteredAttempts
          .where((attempt) => attempt.locationId == widget.locationNamesToIds[filterLocation])
          .toList();
    }
    if (filterSendType != null) {
      filteredAttempts =
          filteredAttempts.where((attempt) => attempt.sendType == filterSendType).toList();
    }
    if (filterCategory != null) {
      filteredAttempts = filteredAttempts
          .where((attempt) => attempt.climbCategories.contains(filterCategory))
          .toList();
    }

    return filteredAttempts;
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
}

class AttemptsByTimeSeries {
  final int hour;
  final int count;

  AttemptsByTimeSeries(this.hour, this.count);
}
