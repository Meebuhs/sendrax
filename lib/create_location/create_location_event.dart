import 'package:sendrax/models/location.dart';

abstract class CreateLocationEvent {}

class ClearGradesEvent extends CreateLocationEvent {}

class ClearLocationEvent extends CreateLocationEvent {}

class GradesUpdatedEvent extends CreateLocationEvent {
  GradesUpdatedEvent(this.isEdit, this.gradeIds);

  final bool isEdit;
  final List<String> gradeIds;
}

class LocationUpdatedEvent extends CreateLocationEvent {
  LocationUpdatedEvent(this.location);

  final Location location;
}

class CreateLocationErrorEvent extends CreateLocationEvent {}
