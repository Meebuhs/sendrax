import 'package:sendrax/models/climb.dart';

abstract class LocationEvent {}

class ClearDataEvent extends LocationEvent {}

class ClimbsUpdatedEvent extends LocationEvent {
  ClimbsUpdatedEvent(this.climbs);

  final List<Climb> climbs;
}

class SectionsUpdatedEvent extends LocationEvent {
  SectionsUpdatedEvent(this.sections);

  final List<String> sections;
}

class LocationErrorEvent extends LocationEvent {}
