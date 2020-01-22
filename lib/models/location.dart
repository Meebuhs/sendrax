import 'climb.dart';

class SelectedLocation {
  SelectedLocation(this.id, this.displayName, this.gradesId);

  final String id;
  final String displayName;
  final String gradesId;
}

class Location {
  Location(this.id, this.displayName, this.gradesId, this.categories, [this.sections, this.climbs]);

  final String id;
  final String displayName;
  final String gradesId;
  final List<String> categories;
  final List<String> sections;
  final List<Climb> climbs;

  Map<String, dynamic> get map {
    return {
      "id": id,
      "displayName": displayName,
      "gradesId": gradesId,
      "sections": sections,
      "climbs": climbs
    };
  }
}
