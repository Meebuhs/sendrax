import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/location.dart';

class MainState {
  final bool loading;
  final List<Attempt> attempts;
  final List<Location> locations;
  final List<String> categories;

  MainState._internal(this.loading, this.attempts, this.locations, this.categories);

  factory MainState.initial() => MainState._internal(true, <Attempt>[], <Location>[], <String>[]);

  factory MainState.loading(bool loading, MainState state) =>
      MainState._internal(loading, state.attempts, state.locations, state.categories);

  factory MainState.updateAttempts(bool loading, List<Attempt> attempts, MainState state) =>
      MainState._internal(loading, attempts, state.locations, state.categories);

  factory MainState.updateLocations(bool loading, List<Location> locations, MainState state) =>
      MainState._internal(loading, state.attempts, locations, state.categories);

  factory MainState.updateCategories(bool loading, List<String> categories, MainState state) =>
      MainState._internal(loading, state.attempts, state.locations, categories);
}
