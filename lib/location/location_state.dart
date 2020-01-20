import 'package:sendrax/models/climb.dart';

class LocationState {
  final bool loading;
  final List<Climb> climbs;
  final List<String> sections;
  final List<String> grades;
  final bool error;

  LocationState._internal(this.loading, this.climbs, this.sections,
      this.grades, {this.error = false});

  factory LocationState.initial() =>
      LocationState._internal(true, <Climb>[], <String>[], <String>[]);

  factory LocationState.loading(bool isLoading, List<Climb> climbs,
      List<String> sections, List<String> grades) =>
      LocationState._internal(isLoading, climbs, sections, grades);

  factory LocationState.climbs(List<Climb> climbs, LocationState state) =>
      LocationState._internal(
          state.loading, climbs, state.sections, state.grades);

  factory LocationState.error(LocationState state) =>
      LocationState._internal(
          state.loading, state.climbs, state.sections, state.grades,
          error: true);
}
