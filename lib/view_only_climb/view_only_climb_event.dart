import 'package:sendrax/models/climb.dart';

abstract class ViewOnlyClimbEvent {}

class ClimbClearedEvent extends ViewOnlyClimbEvent {}

class ClimbUpdatedEvent extends ViewOnlyClimbEvent {
  ClimbUpdatedEvent(this.climb);

  final Climb climb;
}

class ViewOnlyClimbErrorEvent extends ViewOnlyClimbEvent {}
