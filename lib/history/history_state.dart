import 'package:sendrax/models/attempt.dart';

class HistoryState {
  final bool loading;
  final bool reachedEnd;
  final List<Attempt> attempts;

  // @formatter:off
  HistoryState._internal(this.loading, this.reachedEnd, this.attempts);

  factory HistoryState.initial() => HistoryState._internal(true, false, <Attempt>[]);

  factory HistoryState.updateAttempts(
      bool loading, bool reachedEnd,  List<Attempt> attempts) =>
      HistoryState._internal(loading, reachedEnd, attempts);
}
// @formatter:on
