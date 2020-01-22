import 'package:sendrax/models/climb.dart';

class LocationState {
  final bool loading;
  final List<Climb> climbs;
  final List<String> sections;
  final List<String> grades;

  // @formatter:off
  LocationState._internal(this.loading, this.climbs, this.sections, this.grades);

  factory LocationState.initial() =>
      LocationState._internal(true, <Climb>[], <String>[], <String>[]);

  factory LocationState.loading(bool isLoading, LocationState state) =>
      LocationState._internal(isLoading, state.climbs, state.sections, state.grades);

  factory LocationState.updateClimbs(bool loading, List<Climb> climbs, LocationState state) =>
      LocationState._internal(loading, climbs, state.sections, state.grades);

  factory LocationState.updateSections(bool loading, List<String> sections, LocationState state) =>
      LocationState._internal(loading, state.climbs, sections, state.grades);

  factory LocationState.clearData(bool loading,) =>
      LocationState._internal(loading, <Climb>[], <String>[], <String>[]);
}
// @formatter:on
