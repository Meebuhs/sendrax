import 'attempt.dart';

class Climb {
  Climb(this.displayName, this.grade, this.section, this.categories,
      [this.attempts]);

  final String displayName;
  final String grade;
  final String section;
  final List<String> categories;
  final List<Attempt> attempts;
}
