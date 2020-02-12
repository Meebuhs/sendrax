import 'package:sendrax/models/attempt.dart';

class HistoryState {
  final bool loading;
  final bool reachedEnd;
  String filterGrade;
  String filterLocation;
  String filterCategory;
  final List<Attempt> attempts;

  HistoryState._internal(this.loading, this.reachedEnd, this.filterGrade, this.filterLocation,
      this.filterCategory, this.attempts);

  factory HistoryState.initial() =>
      HistoryState._internal(true, false, null, null, null, <Attempt>[]);

  factory HistoryState.loading(bool loading, HistoryState state) => HistoryState._internal(
      loading,
      state.reachedEnd,
      state.filterGrade,
      state.filterLocation,
      state.filterCategory,
      state.attempts);

  factory HistoryState.clearAttempts(HistoryState state) => HistoryState._internal(true,
      state.reachedEnd, state.filterGrade, state.filterLocation, state.filterCategory, <Attempt>[]);

  factory HistoryState.updateAttempts(
          bool loading, bool reachedEnd, List<Attempt> attempts, HistoryState state) =>
      HistoryState._internal(loading, reachedEnd, state.filterGrade, state.filterLocation,
          state.filterCategory, attempts);

  factory HistoryState.setFilterGrade(String filterGrade, HistoryState state) =>
      HistoryState._internal(state.loading, state.reachedEnd, filterGrade, state.filterLocation,
          state.filterCategory, state.attempts);

  factory HistoryState.setFilterLocation(String filterLocation, HistoryState state) =>
      HistoryState._internal(state.loading, state.reachedEnd, state.filterGrade, filterLocation,
          state.filterCategory, state.attempts);

  factory HistoryState.setFilterCategory(String filterCategory, HistoryState state) =>
      HistoryState._internal(state.loading, state.reachedEnd, state.filterGrade,
          state.filterLocation, filterCategory, state.attempts);

  factory HistoryState.clearFilters(HistoryState state) =>
      HistoryState._internal(state.loading, state.reachedEnd, null, null, null, state.attempts);
}
