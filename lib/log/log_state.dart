import 'package:sendrax/models/location.dart';

class LogState {
  final bool loading;
  final List<Location> locations;
  final List<String> categories;

  LogState._internal(this.loading, this.locations, this.categories);

  factory LogState.initial() => LogState._internal(true, <Location>[], <String>[]);

  factory LogState.loading(bool loading, LogState state) =>
      LogState._internal(loading, state.locations, state.categories);

  factory LogState.updateLocations(bool loading, List<Location> locations, LogState state) =>
      LogState._internal(loading, locations, state.categories);

  factory LogState.updateCategories(bool loading, List<String> categories, LogState state) =>
      LogState._internal(loading, state.locations, categories);
}
