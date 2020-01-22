import 'package:sendrax/models/attempt.dart';

class ClimbState {
  final bool loading;
  final List<Attempt> attempts;
  final String sendType;
  final bool warmup;
  final List<String> drills;
  final String notes;

  // @formatter:off
  ClimbState._internal(
      this.loading, this.attempts, this.sendType, this.warmup, this.drills, this.notes);

  factory ClimbState.initial() =>
      ClimbState._internal(true, <Attempt>[], "", false, <String>[], "");

  factory ClimbState.loading(bool loading, ClimbState state) => ClimbState._internal(
      state.loading, state.attempts, state.sendType, state.warmup, state.drills, state.notes);

  factory ClimbState.updateAttempts(bool loading, List<Attempt> attempts, ClimbState state) =>
      ClimbState._internal(
          loading, attempts, state.sendType, state.warmup, state.drills, state.notes);
}
// @formatter:on

