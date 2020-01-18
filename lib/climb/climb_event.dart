import 'package:sendrax/models/attempt.dart';

abstract class ClimbEvent {}

class ClearAttemptsEvent extends ClimbEvent {}

class AttemptsUpdatedEvent extends ClimbEvent {
  AttemptsUpdatedEvent(this.attempts);

  final List<Attempt> attempts;
}

class ClimbErrorEvent extends ClimbEvent {}
