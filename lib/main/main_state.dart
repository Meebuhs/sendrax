import 'package:sendrax/models/location.dart';

class MainState {
  final bool isLoading;
  final List<Location> locations;
  final SelectedLocation selected;
  final bool loggedIn;

  MainState._internal(this.isLoading, this.locations,
      {this.loggedIn = true, this.selected});

  factory MainState.initial() => MainState._internal(false, List<Location>(0));

  factory MainState.isLoading(bool isLoading, MainState state) =>
      MainState._internal(isLoading, state.locations);

  factory MainState.locations(List<Location> location, MainState state) =>
      MainState._internal(state.isLoading, location);

  factory MainState.openLocation(SelectedLocation location, MainState state) =>
      MainState._internal(false, state.locations, selected: location);

  factory MainState.logout(MainState state) =>
      MainState._internal(false, state.locations, loggedIn: false);

  factory MainState.reset(MainState state) =>
      MainState._internal(state.isLoading, state.locations);
}
