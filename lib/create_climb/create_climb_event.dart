abstract class CreateClimbEvent {}

class GradesClearedEvent extends CreateClimbEvent {}

class GradesUpdatedEvent extends CreateClimbEvent {
  GradesUpdatedEvent(this.grades);

  final List<String> grades;
}

class GradeSelectedEvent extends CreateClimbEvent {
  GradeSelectedEvent(this.grade);

  final String grade;
}

class SectionSelectedEvent extends CreateClimbEvent {
  SectionSelectedEvent(this.section);

  final String section;
}

class CategoriesUpdatedEvent extends CreateClimbEvent {
  CategoriesUpdatedEvent(this.selectedCategories);

  final List<String> selectedCategories;
}

class CreateClimbErrorEvent extends CreateClimbEvent {}
