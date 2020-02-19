class HistoryState {
  String filterGrade;
  String filterLocation;
  String filterCategory;

  HistoryState._internal(this.filterGrade, this.filterLocation, this.filterCategory);

  factory HistoryState.initial() => HistoryState._internal(null, null, null);

  factory HistoryState.loading(bool loading, HistoryState state) =>
      HistoryState._internal(state.filterGrade, state.filterLocation, state.filterCategory);

  factory HistoryState.setFilterGrade(String filterGrade, HistoryState state) =>
      HistoryState._internal(filterGrade, state.filterLocation, state.filterCategory);

  factory HistoryState.setFilterLocation(String filterLocation, HistoryState state) =>
      HistoryState._internal(state.filterGrade, filterLocation, state.filterCategory);

  factory HistoryState.setFilterCategory(String filterCategory, HistoryState state) =>
      HistoryState._internal(state.filterGrade, state.filterLocation, filterCategory);

  factory HistoryState.clearFilters(HistoryState state) => HistoryState._internal(null, null, null);
}
