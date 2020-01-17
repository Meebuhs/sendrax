import 'package:sendrax/models/climb.dart';

class LocationState {
  final bool isLoading;
  final List<Climb> climbs;
  final bool error;

  LocationState._internal(this.isLoading, this.climbs, {this.error = false});

  factory LocationState.initial() => LocationState._internal(true, <Climb>[]);

  factory LocationState.isLoading(bool isLoading, LocationState state) =>
      LocationState._internal(isLoading, state.climbs);

  factory LocationState.climbs(List<Climb> climbs, LocationState state) =>
      LocationState._internal(state.isLoading, climbs);

  factory LocationState.error(LocationState state) =>
      LocationState._internal(state.isLoading, state.climbs, error: true);
}
