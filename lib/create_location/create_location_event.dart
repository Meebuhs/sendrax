import 'package:sendrax/models/location.dart';

abstract class CreateLocationEvent {}

class GradesClearedEvent extends CreateLocationEvent {}

class LocationClearedEvent extends CreateLocationEvent {}

class GradesUpdatedEvent extends CreateLocationEvent {
  GradesUpdatedEvent(this.availableGrades);

  final List<String> availableGrades;
}

class LocationUpdatedEvent extends CreateLocationEvent {
  LocationUpdatedEvent(this.location);

  final Location location;
}

class GradeSelectedEvent extends CreateLocationEvent {
  GradeSelectedEvent(this.grade);

  final String grade;
}

class CreateLocationErrorEvent extends CreateLocationEvent {}
