import 'package:sendrax/models/attempt.dart';

abstract class HistoryEvent {}

class ClearAttemptsEvent extends HistoryEvent {}

class AttemptsUpdatedEvent extends HistoryEvent {
  AttemptsUpdatedEvent(this.reachedEnd, this.attempts);

  final bool reachedEnd;
  final List<Attempt> attempts;
}

class HistoryErrorEvent extends HistoryEvent {}
