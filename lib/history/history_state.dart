class HistoryState {
  String filterGradeSet;
  String filterGrade;
  String filterLocation;
  String filterCategory;

  HistoryState._internal(
      this.filterGradeSet, this.filterGrade, this.filterLocation, this.filterCategory);

  factory HistoryState.initial() => HistoryState._internal(null, null, null, null);

  factory HistoryState.loading(bool loading, HistoryState state) => HistoryState._internal(
      state.filterGradeSet, state.filterGrade, state.filterLocation, state.filterCategory);

  factory HistoryState.setFilterGradeSet(String filterGradeSet, HistoryState state) =>
      HistoryState._internal(
          filterGradeSet, state.filterGrade, state.filterLocation, state.filterCategory);

  factory HistoryState.setFilterGrade(String filterGrade, HistoryState state) =>
      HistoryState._internal(
          state.filterGradeSet, filterGrade, state.filterLocation, state.filterCategory);

  factory HistoryState.setFilterLocation(String filterLocation, HistoryState state) =>
      HistoryState._internal(
          state.filterGradeSet, state.filterGrade, filterLocation, state.filterCategory);

  factory HistoryState.setFilterCategory(String filterCategory, HistoryState state) =>
      HistoryState._internal(
          state.filterGradeSet, state.filterGrade, state.filterLocation, filterCategory);

  factory HistoryState.clearFilters(HistoryState state) => HistoryState._internal(null, null, null, null);
}
