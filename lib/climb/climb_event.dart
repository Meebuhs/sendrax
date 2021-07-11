import 'package:sendrax/models/attempt.dart';

abstract class ClimbEvent {}

class AttemptsClearedEvent extends ClimbEvent {}

class AttemptsUpdatedEvent extends ClimbEvent {
  AttemptsUpdatedEvent(this.attempts);

  final List<Attempt> attempts;
}

class DownclimbedToggledEvent extends ClimbEvent {
  DownclimbedToggledEvent(this.downclimbed);

  final bool downclimbed;
}

class ClimbErrorEvent extends ClimbEvent {}
