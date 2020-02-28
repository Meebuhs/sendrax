import 'package:sendrax/models/climb.dart';

class LocationState {
  final bool loading;
  String filterSection;
  String filterGrade;
  String filterCategory;
  final List<Climb> climbs;

  LocationState._internal(
      this.loading, this.filterSection, this.filterGrade, this.filterCategory, this.climbs);

  factory LocationState.initial() => LocationState._internal(true, null, null, null, <Climb>[]);

  factory LocationState.loading(bool loading, LocationState state) => LocationState._internal(
      loading, state.filterSection, state.filterGrade, state.filterCategory, state.climbs);

  factory LocationState.updateClimbs(bool loading, List<Climb> climbs, LocationState state) =>
      LocationState._internal(
          loading, state.filterSection, state.filterGrade, state.filterCategory, climbs);

  factory LocationState.clearData(bool loading, LocationState state) =>
      LocationState._internal(loading, null, null, null, <Climb>[]);

  factory LocationState.setFilterSection(String filterSection, LocationState state) =>
      LocationState._internal(
          state.loading, filterSection, state.filterGrade, state.filterCategory, state.climbs);

  factory LocationState.setFilterGrade(String filterGrade, LocationState state) =>
      LocationState._internal(
          state.loading, state.filterSection, filterGrade, state.filterCategory, state.climbs);

  factory LocationState.setFilterCategory(String filterCategory, LocationState state) =>
      LocationState._internal(
          state.loading, state.filterSection, state.filterGrade, filterCategory, state.climbs);

  factory LocationState.clearFilters(LocationState state) =>
      LocationState._internal(false, null, null, null, state.climbs);
}
