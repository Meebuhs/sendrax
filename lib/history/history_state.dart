import 'package:sendrax/models/attempt.dart';

class HistoryState {
  final bool loading;
  final bool reachedEnd;
  final List<Attempt> attempts;

  // @formatter:off
  HistoryState._internal(this.loading, this.reachedEnd, this.attempts);

  factory HistoryState.initial() => HistoryState._internal(true, false, <Attempt>[]);

  factory HistoryState.loading(bool loading, HistoryState state) =>
      HistoryState._internal(loading, state.reachedEnd, state.attempts);

  factory HistoryState.updateAttempts(
      bool reachedEnd,  List<Attempt> attempts, HistoryState state) =>
      HistoryState._internal(false, reachedEnd, attempts);
}
// @formatter:on
