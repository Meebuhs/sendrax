import 'package:sendrax/models/attempt.dart';

class ClimbState {
  final bool isLoading;
  final List<Attempt> attempts;
  final String sendType;
  final bool warmup;
  final List<String> drills;
  final String notes;
  final bool error;

  ClimbState._internal(
      this.isLoading, this.attempts, this.sendType, this.warmup, this.drills, this.notes,
      {this.error = false});

  factory ClimbState.initial() =>
      ClimbState._internal(true, <Attempt>[], "", false, <String>[], "");

  factory ClimbState.isLoading(bool isLoading, List<Attempt> attempts, ClimbState state) =>
      ClimbState._internal(
          isLoading, attempts, state.sendType, state.warmup, state.drills, state.notes);

  factory ClimbState.attempts(List<Attempt> attempts, ClimbState state) => ClimbState._internal(
      state.isLoading, attempts, state.sendType, state.warmup, state.drills, state.notes);

  factory ClimbState.sendType(String sendType, ClimbState state) => ClimbState._internal(
      state.isLoading, state.attempts, sendType, state.warmup, state.drills, state.notes);

  factory ClimbState.warmup(bool warmup, ClimbState state) => ClimbState._internal(
      state.isLoading, state.attempts, state.sendType, warmup, state.drills, state.notes);

  factory ClimbState.drills(List<String> drills, ClimbState state) => ClimbState._internal(
      state.isLoading, state.attempts, state.sendType, state.warmup, drills, state.notes);

  factory ClimbState.notes(String notes, ClimbState state) => ClimbState._internal(
      state.isLoading, state.attempts, state.sendType, state.warmup, state.drills, notes);

  factory ClimbState.error(ClimbState state) => ClimbState._internal(
      state.isLoading, state.attempts, state.sendType, state.warmup, state.drills, state.notes,
      error: true);
}
