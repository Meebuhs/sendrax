import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/models/location_repo.dart';
import 'package:sendrax/models/storage_repo.dart';
import 'package:sendrax/models/user_repo.dart';

import 'main_event.dart';
import 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  StreamSubscription<List<Location>> locationsSubscription;
  StreamSubscription<List<String>> categoriesSubscription;

  @override
  MainState get initialState {
    _retrieveUserLocations();
    _retrieveUserCategories();
    return MainState.initial();
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
      add(MainErrorEvent());
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
      add(MainErrorEvent());
    }
  }

  @override
  Stream<MainState> mapEventToState(MainEvent event) async* {
    if (event is ClearLocationsEvent) {
      yield MainState.updateLocations(true, <Location>[], state);
    } else if (event is ClearCategoriesEvent) {
      yield MainState.updateCategories(true, <String>[], state);
    } else if (event is LocationsUpdatedEvent) {
      yield MainState.updateLocations(false, event.locations, state);
    } else if (event is CategoriesUpdatedEvent) {
      yield MainState.updateCategories(state.loading, event.categories, state);
    } else if (event is MainErrorEvent) {
      yield MainState.loading(false, state);
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
