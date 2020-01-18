import 'attempt.dart';

class Climb {
  Climb(this.id, this.displayName, this.grade, this.locationId, this.section,
      this.archived, this.categories, [this.attempts]);

  final String id;
  final String displayName;
  final String grade;
  final String locationId;
  final String section;
  final bool archived;
  final List<String> categories;
  final List<Attempt> attempts;
}
