import 'package:sendrax/models/location.dart';

class MainState {
  final bool loading;
  final List<Location> locations;
  final List<String> categories;

  MainState._internal(this.loading, this.locations, this.categories);

  factory MainState.initial() => MainState._internal(true, <Location>[], <String>[]);

  factory MainState.loading(bool loading, MainState state) =>
      MainState._internal(loading, state.locations, state.categories);

  factory MainState.updateLocations(bool loading, List<Location> locations, MainState state) =>
      MainState._internal(loading, locations, state.categories);

  factory MainState.updateCategories(bool loading, List<String> categories, MainState state) =>
      MainState._internal(loading, state.locations, categories);
}
