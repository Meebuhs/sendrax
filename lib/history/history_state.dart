import 'package:sendrax/models/attempt.dart';

class HistoryState {
  final bool loading;
  final List<Attempt> attempts;

  // @formatter:off
  HistoryState._internal(this.loading, this.attempts);

  factory HistoryState.initial() => HistoryState._internal(true, <Attempt>[]);

  factory HistoryState.loading(bool loading, HistoryState state) =>
      HistoryState._internal(loading, state.attempts);

  factory HistoryState.updateAttempts(bool loading, List<Attempt> attempts) =>
      HistoryState._internal(loading, attempts);
}
// @formatter:on
