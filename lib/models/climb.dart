import 'attempt.dart';

class SelectedClimb {
  SelectedClimb(this.id, this.displayName);

  final String id;
  final String displayName;
}

class Climb {
  Climb(this.id, this.displayName, this.locationId, this.grade, this.gradeSet, this.section,
      this.archived, this.categories,
      [this.attempts]);

  final String id;
  final String displayName;
  final String locationId;
  final String grade;
  final String gradeSet;
  final String section;
  final bool archived;
  final List<String> categories;
  final List<Attempt> attempts;

  Map<String, dynamic> get map {
    return {
      "id": id,
      "displayName": displayName,
      "locationId": locationId,
      "grade": grade,
      "gradeSet": gradeSet,
      "section": section,
      "archived": archived,
      "categories": categories,
    };
  }
}
