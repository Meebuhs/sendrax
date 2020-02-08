import 'package:sendrax/models/attempt.dart';

abstract class HistoryEvent {}

class ClearAttemptsEvent extends HistoryEvent {}

class AttemptsUpdatedEvent extends HistoryEvent {
  AttemptsUpdatedEvent(this.attempts);

  final List<Attempt> attempts;
}

class HistoryErrorEvent extends HistoryEvent {}
