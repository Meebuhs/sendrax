import 'climb.dart';

class SelectedLocation {
  SelectedLocation(this.id, this.displayName);

  final String id;
  final String displayName;
}

class Location {
  Location(this.id, this.displayName, [this.gradesId, this.sections, this.climbs]);

  final String id;
  final String displayName;
  final String gradesId;
  final List<String> sections;
  final List<Climb> climbs;

  Map<String, dynamic> get map {
    return {
      "id": id,
      "displayName": displayName,
      "grades": gradesId,
      "sections": sections,
      "climbs": climbs
    };
  }
}
