import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:sendrax/location/location_event.dart';
import 'package:sendrax/location/location_state.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/models/location_repo.dart';
import 'package:sendrax/models/user_repo.dart';

import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc(this.locationId);

  final String locationId;
  StreamSubscription<List<Climb>> climbSubscription;
  StreamSubscription<Location> locationSubscription;

  void _retrieveClimbsForThisLocation() async {
    add(ClearClimbsEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    if (user != null) {
      climbSubscription = LocationRepo.getInstance()
          .getClimbsForLocation(locationId, user)
          .listen((climbs) {
        add(ClimbsUpdatedEvent(
            climbs..sort((a, b) => a.section.compareTo(b.section))));
      });
    } else {
      add(LocationErrorEvent());
    }
  }

  void _retrieveSectionsForThisLocation() async {
    add(ClearSectionsEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    if (user != null) {
      locationSubscription = LocationRepo.getInstance()
          .getSectionsForLocation(locationId, user)
          .listen((location) {
        add(SectionsUpdatedEvent(location.sections));
      });
    } else {
      add(LocationErrorEvent());
    }
  }

  @override
  LocationState get initialState {
    _retrieveClimbsForThisLocation();
    _retrieveSectionsForThisLocation();
    return LocationState.initial();
  }

  @override
  Stream<LocationState> mapEventToState(LocationEvent event) async* {
    if (event is ClearClimbsEvent) {
      yield LocationState.isLoading(
          true, <Climb>[], state.sections, state.grades);
    } else if (event is ClimbsUpdatedEvent) {
      yield LocationState.isLoading(
          false, event.climbs, state.sections, state.grades);
    } else if (event is ClearSectionsEvent) {
      yield LocationState.isLoading(
          true, state.climbs, <String>[], state.grades);
    } else if (event is SectionsUpdatedEvent) {
      yield LocationState.isLoading(
          false, state.climbs, event.sections, state.grades);
    } else if (event is LocationErrorEvent) {
      yield LocationState.isLoading(
          false, state.climbs, state.sections, state.grades);
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
