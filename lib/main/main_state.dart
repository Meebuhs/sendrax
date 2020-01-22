import 'package:sendrax/models/location.dart';

class MainState {
  final bool loading;
  final List<Location> locations;
  final SelectedLocation selected;
  final bool loggedIn;

  MainState._internal(this.loading, this.locations, {this.loggedIn = true, this.selected});

  factory MainState.initial() => MainState._internal(true, <Location>[]);

  factory MainState.loading(bool loading, MainState state) =>
      MainState._internal(loading, state.locations);

  factory MainState.updateLocations(bool loading, List<Location> locations, MainState state) =>
      MainState._internal(loading, locations);
}
