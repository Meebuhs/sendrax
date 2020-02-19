abstract class StatsEvent {}

class CountUpdatedEvent extends StatsEvent {
  CountUpdatedEvent(this.count);

  final int count;
}

class StatsErrorEvent extends StatsEvent {}
