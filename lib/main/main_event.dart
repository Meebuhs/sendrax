import 'package:sendrax/models/location.dart';

abstract class MainEvent {}

class ClearLocationsEvent extends MainEvent {}

class LocationsUpdatedEvent extends MainEvent {
  LocationsUpdatedEvent(this.locations);

  final List<Location> locations;
}

class MainErrorEvent extends MainEvent {}
