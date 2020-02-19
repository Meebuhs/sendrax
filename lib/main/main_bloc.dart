import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/attempt_repo.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/models/location_repo.dart';
import 'package:sendrax/models/storage_repo.dart';
import 'package:sendrax/models/user.dart';
import 'package:sendrax/models/user_repo.dart';

import 'main_event.dart';
import 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  StreamSubscription<List<Location>> locationsSubscription;
  StreamSubscription<List<Attempt>> attemptsSubscription;
  StreamSubscription<List<String>> categoriesSubscription;

  @override
  MainState get initialState {
    _retrieveUserData();
    return MainState.initial();
  }

  void _retrieveUserData() async {
    final user = await UserRepo.getInstance().getCurrentUser();
    if (user != null) {
      _retrieveUserAttempts(user);
      _retrieveUserLocations(user);
      _retrieveUserCategories(user);
    } else {
      add(MainErrorEvent());
    }
  }

  void _retrieveUserAttempts(User user) async {
    add(ClearAttemptsEvent());
    attemptsSubscription = AttemptRepo.getInstance().getAttempts(user).listen((attempts) {
      add(AttemptsUpdatedEvent(attempts));
    });
  }

  void _retrieveUserLocations(User user) async {
    add(ClearLocationsEvent());
    locationsSubscription =
        LocationRepo.getInstance().getLocationsForUser(user).listen((locations) async {
      Stream<Location> processedLocationsStream =
          Stream.fromIterable(locations).asyncMap((location) async {
        if (location.imageUri != "") {
          final String url = await StorageRepo.getInstance().decodeUri(location.imageUri);
          return Location(location.id, location.displayName, url, location.imageUri,
              location.gradeSet, location.grades, location.sections, location.climbs);
        } else {
          return location;
        }
      });
      final List<Location> processedLocations = await processedLocationsStream.toList();
      add(LocationsUpdatedEvent(
          processedLocations..sort((a, b) => a.displayName.compareTo(b.displayName))));
    });
  }

  void _retrieveUserCategories(User user) async {
    add(ClearCategoriesEvent());
    categoriesSubscription = UserRepo.getInstance().getUserCategories(user).listen((categories) {
      add(CategoriesUpdatedEvent(categories));
    });
  }

  @override
  Stream<MainState> mapEventToState(MainEvent event) async* {
    if (event is ClearAttemptsEvent) {
      yield MainState.updateAttempts(true, <Attempt>[], state);
    } else if (event is ClearLocationsEvent) {
      yield MainState.updateLocations(true, <Location>[], state);
    } else if (event is ClearCategoriesEvent) {
      yield MainState.updateCategories(true, <String>[], state);
    } else if (event is AttemptsUpdatedEvent) {
      yield MainState.updateAttempts(state.loading, event.attempts, state);
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
    if (attemptsSubscription != null) {
      attemptsSubscription.cancel();
    }
    if (locationsSubscription != null) {
      locationsSubscription.cancel();
    }
    if (categoriesSubscription != null) {
      categoriesSubscription.cancel();
    }
    return super.close();
  }
}
