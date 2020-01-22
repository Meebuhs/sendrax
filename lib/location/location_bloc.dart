import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:sendrax/location/location_event.dart';
import 'package:sendrax/location/location_state.dart';
import 'package:sendrax/location/location_view.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/climb_repo.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/models/location_repo.dart';
import 'package:sendrax/models/user.dart';
import 'package:sendrax/models/user_repo.dart';

import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc(this.location, this.categories);

  final SelectedLocation location;
  final List<String> categories;
  StreamSubscription<List<Climb>> climbSubscription;
  StreamSubscription<Location> locationSubscription;

  @override
  LocationState get initialState {
    _retrieveLocationData();
    return LocationState.initial(location, categories);
  }

  void _retrieveLocationData() async {
    add(ClearDataEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    _retrieveClimbsForThisLocation(user);
    _retrieveSectionsForThisLocation(user);
  }

  void _retrieveClimbsForThisLocation(User user) async {
    if (user != null) {
      climbSubscription =
          LocationRepo.getInstance().getClimbsForLocation(location.id, user).listen((climbs) {
        add(ClimbsUpdatedEvent(climbs..sort((a, b) => a.section.compareTo(b.section))));
      });
    } else {
      add(LocationErrorEvent());
    }
  }

  void _retrieveSectionsForThisLocation(User user) async {
    if (user != null) {
      locationSubscription =
          LocationRepo.getInstance().getSectionsForLocation(location.id, user).listen((location) {
        add(SectionsUpdatedEvent(location.sections));
      });
    } else {
      add(LocationErrorEvent());
    }
  }

  void retrieveClimb(Climb climb, LocationWidget view) async {
    final currentUser = await UserRepo.getInstance().getCurrentUser();
    ClimbRepo.getInstance().getClimb(climb, currentUser).then((climb) {
      view.navigateToClimb(climb);
    });
  }

  @override
  Stream<LocationState> mapEventToState(LocationEvent event) async* {
    if (event is ClearDataEvent) {
      yield LocationState.clearData(true, state);
    } else if (event is ClimbsUpdatedEvent) {
      yield LocationState.updateClimbs(false, event.climbs, state);
    } else if (event is SectionsUpdatedEvent) {
      yield LocationState.updateSections(false, event.sections, state);
    } else if (event is LocationErrorEvent) {
      yield LocationState.loading(false, state);
    }
  }

  @override
  Future<void> close() {
    if (locationSubscription != null) {
      locationSubscription.cancel();
    }
    if (climbSubscription != null) {
      climbSubscription.cancel();
    }
    return super.close();
  }
}
