import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/location.dart';

abstract class MainEvent {}

class ClearAttemptsEvent extends MainEvent {}

class AttemptsUpdatedEvent extends MainEvent {
  AttemptsUpdatedEvent(this.attempts);

  final List<Attempt> attempts;
}

class ClearLocationsEvent extends MainEvent {}

class LocationsUpdatedEvent extends MainEvent {
  LocationsUpdatedEvent(this.locations);

  final List<Location> locations;
}

class ClearCategoriesEvent extends MainEvent {}

class CategoriesUpdatedEvent extends MainEvent {
  CategoriesUpdatedEvent(this.categories);

  final List<String> categories;
}

class MainErrorEvent extends MainEvent {}
