abstract class CreateGradeSetEvent {}

class GradeAddedEvent extends CreateGradeSetEvent {
  GradeAddedEvent(this.grade);

  final String grade;
}

class GradeRemovedEvent extends CreateGradeSetEvent {
  GradeRemovedEvent(this.grade);

  final String grade;
}

class GradeErrorEvent extends CreateGradeSetEvent {
  GradeErrorEvent(this.errorMessage);

  final String errorMessage;
}

