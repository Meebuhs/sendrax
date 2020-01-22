import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/location.dart';

class LocationState {
  final bool loading;
  final String locationId;
  final String gradesId;
  final List<Climb> climbs;
  final List<String> sections;

  // @formatter:off
  LocationState._internal(this.loading, this.locationId, this.gradesId, this.climbs, this.sections);

  factory LocationState.initial(SelectedLocation location) =>
      LocationState._internal(true, location.id, location.gradesId, <Climb>[], <String>[]);

  factory LocationState.loading(bool loading, LocationState state) =>
      LocationState._internal(loading, state.locationId, state.gradesId, state.climbs,
          state.sections);

  factory LocationState.updateClimbs(bool loading, List<Climb> climbs, LocationState state) =>
      LocationState._internal(loading, state.locationId, state.gradesId, climbs, state.sections);

  factory LocationState.updateSections(bool loading, List<String> sections, LocationState state) =>
      LocationState._internal(loading, state.locationId, state.gradesId, state.climbs, sections);

  factory LocationState.clearData(bool loading, LocationState state) =>
      LocationState._internal(loading, state.locationId, state.gradesId, <Climb>[], <String>[]);
}
// @formatter:on
