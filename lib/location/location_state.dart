import 'package:sendrax/models/climb.dart';

class LocationState {
  final bool loading;
  String filterGrade;
  String filterSection;
  final List<Climb> climbs;
  final List<String> sections;
  final List<String> grades;

  // @formatter:off
  LocationState._internal(
      this.loading, this.filterGrade, this.filterSection, this.climbs, this.sections, this.grades);

  factory LocationState.initial() =>
      LocationState._internal(true, null, null, <Climb>[], <String>[], <String>[]);

  factory LocationState.loading(bool loading, LocationState state) => LocationState._internal(
      loading, state.filterGrade, state.filterSection, state.climbs, state.sections, state.grades);

  factory LocationState.updateClimbs(bool loading, List<Climb> climbs, LocationState state) =>
      LocationState._internal(
          loading, state.filterGrade, state.filterSection, climbs, state.sections, state.grades);

  factory LocationState.updateSections(bool loading, List<String> sections, LocationState state) =>
      LocationState._internal(
          loading, state.filterGrade, state.filterSection, state.climbs, sections, state.grades);

  factory LocationState.updateGrades(bool loading, List<String> grades, LocationState state) =>
      LocationState._internal(
          loading, state.filterGrade, state.filterSection, state.climbs, state.sections, grades);

  factory LocationState.clearData(bool loading, LocationState state) =>
      LocationState._internal(loading, null, null, <Climb>[], <String>[], <String>[]);

  factory LocationState.setFilterGrade(String filterGrade, LocationState state) =>
      LocationState._internal(state.loading, filterGrade, state.filterSection, state.climbs,
          state.sections, state.grades);

  factory LocationState.setFilterSection(String filterSection, LocationState state) =>
      LocationState._internal(state.loading, state.filterGrade, filterSection, state.climbs,
          state.sections, state.grades);
}
// @formatter:on
