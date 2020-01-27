import 'climb.dart';

class SelectedLocation {
  SelectedLocation(this.id, this.displayName, this.gradeSet);

  final String id;
  final String displayName;
  final String gradeSet;
}

class Location {
  Location(this.id, this.displayName, this.gradeSet, this.categories, [this.sections, this.climbs]);

  final String id;
  final String displayName;
  final String gradeSet;
  final List<String> categories;
  final List<String> sections;
  final List<Climb> climbs;

  Map<String, dynamic> get map {
    return {
      "id": id,
      "displayName": displayName,
      "gradeSet": gradeSet,
      "sections": sections,
      "climbs": climbs
    };
  }
}
