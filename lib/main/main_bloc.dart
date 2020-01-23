import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/models/location_repo.dart';
import 'package:sendrax/models/login_repo.dart';
import 'package:sendrax/models/user_repo.dart';

import 'main_event.dart';
import 'main_state.dart';
import 'main_view.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  StreamSubscription<List<Location>> locationsSubscription;
  StreamSubscription<List<String>> categoriesSubscription;

  void logout(MainWidget view) {
    LoginRepo.getInstance().signOut().then((success) {
      if (success) {
        view.navigateToLogin();
      }
    });
  }

  @override
  MainState get initialState {
    retrieveUserLocations();
    retrieveUserCategories();
    return MainState.initial();
  }

  void retrieveUserLocations() async {
    add(ClearLocationsEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    if (user != null) {
      locationsSubscription =
          LocationRepo.getInstance().getLocationsForUser(user).listen((locations) {
        add(LocationsUpdatedEvent(
            locations..sort((a, b) => a.displayName.compareTo(b.displayName))));
      });
    } else {
      add(MainErrorEvent());
    }
  }

  void retrieveUserCategories() async {
    add(ClearCategoriesEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    if (user != null) {
      categoriesSubscription =
          UserRepo.getInstance().getUserCategories(user).listen((categories) {
        add(CategoriesUpdatedEvent(categories));
      });
    } else {
      add(MainErrorEvent());
    }
  }

  void retrieveLocation(Location location, MainWidget view, List<String> categories) async {
    final currentUser = await UserRepo.getInstance().getCurrentUser();
    LocationRepo.getInstance().getLocation(location, currentUser).then((location) {
      view.navigateToLocation(location, categories);
    });
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
      yield MainState.updateCategories(false, event.categories, state);
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
