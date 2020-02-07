import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/models/location_repo.dart';
import 'package:sendrax/models/storage_repo.dart';
import 'package:sendrax/models/user_repo.dart';

import 'log_event.dart';
import 'log_state.dart';

class LogBloc extends Bloc<LogEvent, LogState> {
  StreamSubscription<List<Location>> locationsSubscription;
  StreamSubscription<List<String>> categoriesSubscription;

  @override
  LogState get initialState {
    _retrieveUserLocations();
    _retrieveUserCategories();
    return LogState.initial();
  }

  void _retrieveUserLocations() async {
    add(ClearLocationsEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    if (user != null) {
      locationsSubscription =
          LocationRepo.getInstance().getLocationsForUser(user).listen((locations) async {
            Stream<Location> processedLocationsStream =
            Stream.fromIterable(locations).asyncMap((location) async {
              if (location.imageUri != "") {
                final String url = await StorageRepo.getInstance().decodeUri(location.imageUri);
                return Location(location.id, location.displayName, url, location.imageUri,
                    location.gradeSet, location.categories, location.sections, location.climbs);
              } else {
                return location;
              }
            });
            final List<Location> processedLocations = await processedLocationsStream.toList();
            add(LocationsUpdatedEvent(
                processedLocations..sort((a, b) => a.displayName.compareTo(b.displayName))));
          });
    } else {
      add(LogErrorEvent());
    }
  }

  void _retrieveUserCategories() async {
    add(ClearCategoriesEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    if (user != null) {
      categoriesSubscription = UserRepo.getInstance().getUserCategories(user).listen((categories) {
        add(CategoriesUpdatedEvent(categories));
      });
    } else {
      add(LogErrorEvent());
    }
  }

  void editCategories(List<String> categories) async {
    final user = await UserRepo.getInstance().getCurrentUser();
    UserRepo.getInstance().setUserCategories(user, categories);
  }

  @override
  Stream<LogState> mapEventToState(LogEvent event) async* {
    if (event is ClearLocationsEvent) {
      yield LogState.updateLocations(true, <Location>[], state);
    } else if (event is ClearCategoriesEvent) {
      yield LogState.updateCategories(true, <String>[], state);
    } else if (event is LocationsUpdatedEvent) {
      yield LogState.updateLocations(false, event.locations, state);
    } else if (event is CategoriesUpdatedEvent) {
      yield LogState.updateCategories(state.loading, event.categories, state);
    } else if (event is LogErrorEvent) {
      yield LogState.loading(false, state);
    }
  }

  @override
  Future<void> close() {
    if (locationsSubscription != null) {
      locationsSubscription.cancel();
    }
    if (categoriesSubscription != null) {
      categoriesSubscription.cancel();
    }
    return super.close();
  }
}
