import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

import 'attempts_by_value.dart';

class AttemptsByLocationChart extends StatelessWidget {
  AttemptsByLocationChart(
      {Key key,
      @required this.attempts,
      @required this.categories,
      @required this.grades,
      @required this.locationNamesToIds,
      @required this.locationNamesToGradeSet})
      : super(key: key);
  final List<Attempt> attempts;
  final List<String> categories;
  final Map<String, List<String>> grades;
  final Map<String, String> locationNamesToIds;
  final Map<String, String> locationNamesToGradeSet;

  @override
  Widget build(BuildContext context) {
    return AttemptsByValueChart(
      attempts: attempts,
      categories: categories,
      grades: grades,
      locationNamesToIds: locationNamesToIds,
      locationNamesToGradeSet: locationNamesToGradeSet,
      buildTicks: buildTicks,
      processAttempt: processAttempt,
      createEmptyMap: createEmptyMap,
      enableFilters: [
        FilterType.gradeSet,
        FilterType.grade,
        FilterType.timeframe,
        FilterType.category
      ],
    );
  }

  List<charts.TickSpec<String>> buildTicks() {
    return locationNamesToIds.keys.toList().map((location) => charts.TickSpec(location)).toList();
  }

  List<String> processAttempt(Attempt attempt) {
    return [
      locationNamesToIds.keys.firstWhere((key) => locationNamesToIds[key] == attempt.locationId)
    ];
  }

  Map<String, int> createEmptyMap() {
    return Map.fromIterable(locationNamesToIds.keys, key: (item) => item, value: (item) => 0);
  }
}
