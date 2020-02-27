import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

import 'attempts_by_value.dart';

class AttemptsByCategoryChart extends StatelessWidget {
  AttemptsByCategoryChart(
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
        FilterType.location
      ],
      rotateLabels: true,
    );
  }

  List<charts.TickSpec<String>> buildTicks() {
    return categories.map((category) => charts.TickSpec(category)).toList();
  }

  List<String> processAttempt(Attempt attempt) {
    return attempt.climbCategories;
  }

  Map<String, int> createEmptyMap() {
    return Map.fromIterable(categories, key: (item) => item, value: (item) => 0);
  }
}
