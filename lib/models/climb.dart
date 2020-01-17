import 'attempt.dart';

class Climb {
  Climb(this.grade, this.section, this.categories, [this.attempts]);

  final String grade;
  final String section;
  final List<String> categories;
  final List<Attempt> attempts;
}
