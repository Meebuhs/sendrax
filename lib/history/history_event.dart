import 'package:sendrax/models/attempt.dart';

abstract class HistoryEvent {}

class ClearAttemptsEvent extends HistoryEvent {}

class AttemptsLoadingEvent extends HistoryEvent {}

class AttemptsUpdatedEvent extends HistoryEvent {
  AttemptsUpdatedEvent(this.reachedEnd, this.attempts);

  final bool reachedEnd;
  final List<Attempt> attempts;
}

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
