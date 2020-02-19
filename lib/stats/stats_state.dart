class StatsState {
  final bool loading;
  final int count;

  StatsState._internal(this.loading, this.count);

  factory StatsState.initial() => StatsState._internal(true, 0);

  factory StatsState.loading(bool loading, StatsState state) =>
      StatsState._internal(loading, state.count);

  factory StatsState.updateCount(int count, StatsState state) =>
      StatsState._internal(false, count);
}
