abstract class HistoryEvent {}

class GradeFilteredEvent extends HistoryEvent {
  GradeFilteredEvent(this.filterGrade);

  final String filterGrade;
}

class LocationFilteredEvent extends HistoryEvent {
  LocationFilteredEvent(this.filterLocation);

  final String filterLocation;
}

class CategoryFilteredEvent extends HistoryEvent {
  CategoryFilteredEvent(this.filterCategory);

  final String filterCategory;
}

class FiltersClearedEvent extends HistoryEvent {}

class HistoryErrorEvent extends HistoryEvent {}
