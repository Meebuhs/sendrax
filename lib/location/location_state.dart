import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/location.dart';

class LocationState {
  final bool loading;
  final String locationId;
  final String gradesId;
  final List<Climb> climbs;
  final List<String> sections;
  final List<String> categories;

  // @formatter:off
  LocationState._internal(
      this.loading, this.locationId, this.gradesId, this.climbs, this.sections, this.categories);

  factory LocationState.initial(SelectedLocation location, List<String> categories) =>
      LocationState._internal(true, location.id, location.gradesId, <Climb>[], <String>[], categories);

  factory LocationState.loading(bool loading, LocationState state) =>
      LocationState._internal(loading, state.locationId, state.gradesId, state.climbs,
          state.sections, state.categories);

  factory LocationState.updateClimbs(bool loading, List<Climb> climbs, LocationState state) =>
      LocationState._internal(
          loading, state.locationId, state.gradesId, climbs, state.sections, state.categories);

  factory LocationState.updateSections(bool loading, List<String> sections, LocationState state) =>
      LocationState._internal(
          loading, state.locationId, state.gradesId, state.climbs, sections, state.categories);

  factory LocationState.clearData(bool loading, LocationState state) =>
      LocationState._internal(
          loading, state.locationId, state.gradesId, <Climb>[], <String>[], state.categories);
}
// @formatter:on
