import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

import 'attempts_by_value.dart';

class AttemptsByTimeChart extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AttemptsByValueChart(
      attempts: attempts,
      categories: categories,
      grades: grades,
      locationNamesToIds: locationNamesToIds,
      buildTicks: buildTicks,
      processAttempt: processAttempt,
      createEmptyMap: createEmptyMap,
      enableFilters: [
        FilterType.gradeSet,
        FilterType.grade,
        FilterType.timeframe,
        FilterType.location,
        FilterType.category
      ],
    );
  }

  List<charts.TickSpec<String>> buildTicks() {
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

  String processAttempt(Attempt attempt) {
    return (attempt.timestamp.toDate().hour).toString();
  }

  Map<String, int> createEmptyMap() {
    return Map.fromIterable(List<int>.generate(24, (i) => i + 1),
        key: (item) => (item - 1).toString(), value: (item) => 0);
  }
}
