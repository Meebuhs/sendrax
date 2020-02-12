import 'package:sendrax/models/climb.dart';

abstract class LocationEvent {}

class ClearDataEvent extends LocationEvent {}

class ClimbsUpdatedEvent extends LocationEvent {
  ClimbsUpdatedEvent(this.climbs);

  final List<Climb> climbs;
}

class GradeFilteredEvent extends LocationEvent {
  GradeFilteredEvent(this.filterGrade);

  final String filterGrade;
}

class SectionFilteredEvent extends LocationEvent {
  SectionFilteredEvent(this.filterSection);

  final String filterSection;
}
class LocationErrorEvent extends LocationEvent {}
