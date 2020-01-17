import 'package:sendrax/models/climb.dart';

abstract class LocationEvent {}

class ClearClimbsEvent extends LocationEvent {}

class ClimbsUpdatedEvent extends LocationEvent {
  ClimbsUpdatedEvent(this.climbs);

  final List<Climb> climbs;
}

class LocationErrorEvent extends LocationEvent {}
