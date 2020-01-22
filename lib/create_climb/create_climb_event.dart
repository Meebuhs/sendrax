abstract class CreateClimbEvent {}

class ClearGradesEvent extends CreateClimbEvent {}

class GradesUpdatedEvent extends CreateClimbEvent {
  GradesUpdatedEvent(this.grades);

  final List<String> grades;
}

class CreateClimbErrorEvent extends CreateClimbEvent {}

