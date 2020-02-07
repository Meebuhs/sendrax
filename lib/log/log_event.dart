import 'package:sendrax/models/location.dart';

abstract class LogEvent {}

class ClearLocationsEvent extends LogEvent {}

class LocationsUpdatedEvent extends LogEvent {
  LocationsUpdatedEvent(this.locations);

  final List<Location> locations;
}

class ClearCategoriesEvent extends LogEvent {}

class CategoriesUpdatedEvent extends LogEvent {
  CategoriesUpdatedEvent(this.categories);

  final List<String> categories;
}

class LogErrorEvent extends LogEvent {}
