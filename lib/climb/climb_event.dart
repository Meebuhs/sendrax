import 'package:sendrax/models/attempt.dart';

abstract class ClimbEvent {}

class AttempsClearedEvent extends ClimbEvent {}

class AttemptsUpdatedEvent extends ClimbEvent {
  AttemptsUpdatedEvent(this.attempts);

  final List<Attempt> attempts;
}

class SendTypeSelectedEvent extends ClimbEvent {
  SendTypeSelectedEvent(this.sendType);

  final String sendType;
}

class DownclimbedToggledEvent extends ClimbEvent {
  DownclimbedToggledEvent(this.downclimbed);

  final bool downclimbed;
}

class ClimbErrorEvent extends ClimbEvent {}
