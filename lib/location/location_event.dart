import 'package:sendrax/models/climb.dart';

abstract class LocationEvent {}

class ClearDataEvent extends LocationEvent {}

class ClimbsUpdatedEvent extends LocationEvent {
  ClimbsUpdatedEvent(this.climbs);

  final List<Climb> climbs;
}

class SectionFilteredEvent extends LocationEvent {
  SectionFilteredEvent(this.filterSection);

  final String filterSection;
}

class GradeFilteredEvent extends LocationEvent {
  GradeFilteredEvent(this.filterGrade);

  final String filterGrade;
}

class StatusFilteredEvent extends LocationEvent {
  StatusFilteredEvent(this.filterStatus);

  final String filterStatus;
}

class CategoryFilteredEvent extends LocationEvent {
  CategoryFilteredEvent(this.filterCategory);

  final String filterCategory;
}

class FiltersClearedEvent extends LocationEvent {}

class LocationErrorEvent extends LocationEvent {}
