import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/location.dart';

class LocationState {
  final bool loading;
  final String locationId;
  final String gradesId;
  String filterGrade;
  String filterSection;
  final List<Climb> climbs;
  final List<String> sections;
  final List<String> grades;
  final List<String> categories;

  // @formatter:off
  LocationState._internal(
      this.loading, this.locationId, this.gradesId, this.filterGrade, this.filterSection,
      this.climbs, this.sections, this.grades, this.categories);

  factory LocationState.initial(SelectedLocation location, List<String> categories) =>
      LocationState._internal(true, location.id, location.gradesId, null, null, <Climb>[],
          <String>[], <String>[], categories);

  factory LocationState.loading(bool loading, LocationState state) =>
      LocationState._internal(loading, state.locationId, state.gradesId, state.filterGrade,
          state.filterSection, state.climbs, state.sections, state.grades, state.categories);

  factory LocationState.updateClimbs(bool loading, List<Climb> climbs, LocationState state) =>
      LocationState._internal(loading, state.locationId, state.gradesId, state.filterGrade,
          state.filterSection, climbs, state.sections, state.grades, state.categories);

  factory LocationState.updateSections(bool loading, List<String> sections, LocationState state) =>
      LocationState._internal(loading, state.locationId, state.gradesId, state.filterGrade,
          state.filterSection, state.climbs, sections, state.grades, state.categories);

  factory LocationState.updateGrades(bool loading, List<String> grades, LocationState state) =>
      LocationState._internal(loading, state.locationId, state.gradesId, state.filterGrade,
          state.filterSection, state.climbs, state.sections, grades, state.categories);

  factory LocationState.clearData(bool loading, LocationState state) =>
      LocationState._internal(loading, state.locationId, state.gradesId, null, null, <Climb>[],
          <String>[], <String>[], state.categories);
}
// @formatter:on
