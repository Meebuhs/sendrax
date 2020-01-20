abstract class CreateLocationEvent {}

class ClearGradesEvent extends CreateLocationEvent {}

class GradesUpdatedEvent extends CreateLocationEvent {
  GradesUpdatedEvent(this.gradeIds);

  final List<String> gradeIds;
}

class GradesErrorEvent extends CreateLocationEvent {}
