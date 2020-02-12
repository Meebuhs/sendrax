import 'package:sendrax/models/climb.dart';

class LocationState {
  final bool loading;
  String filterGrade;
  String filterSection;
  final List<Climb> climbs;

  // @formatter:off
  LocationState._internal(
      this.loading, this.filterGrade, this.filterSection, this.climbs);

  factory LocationState.initial() =>
      LocationState._internal(true, null, null, <Climb>[]);

  factory LocationState.loading(bool loading, LocationState state) =>
      LocationState._internal(loading, state.filterGrade, state.filterSection, state.climbs);

  factory LocationState.updateClimbs(bool loading, List<Climb> climbs, LocationState state) =>
      LocationState._internal(loading, state.filterGrade, state.filterSection, climbs);

  factory LocationState.clearData(bool loading, LocationState state) =>
      LocationState._internal(loading, null, null, <Climb>[]);

  factory LocationState.setFilterGrade(String filterGrade, LocationState state) =>
      LocationState._internal(state.loading, filterGrade, state.filterSection, state.climbs);

  factory LocationState.setFilterSection(String filterSection, LocationState state) =>
      LocationState._internal(state.loading, state.filterGrade, filterSection, state.climbs);
}
// @formatter:on
