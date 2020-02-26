import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:sendrax/models/attempt.dart';

import 'attempts_by_value.dart';

class AttemptsByDayChart extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AttemptsByValueChart(
      attempts: attempts,
      categories: categories,
      grades: grades,
      locationNamesToIds: locationNamesToIds,
      buildTicks: buildTicks,
      processAttempt: processAttempt,
      createEmptyMap: createEmptyMap,
    );
  }

  List<charts.TickSpec<String>> buildTicks() {
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

  String processAttempt(Attempt attempt) {
    return ((attempt.timestamp.toDate().weekday + 6) % 7).toString();
  }

  Map<String, int> createEmptyMap() {
    return Map.fromIterable(List<int>.generate(7, (i) => i),
        key: (item) => item.toString(), value: (item) => 0);
  }
}
