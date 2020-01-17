import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:sendrax/location/location_event.dart';
import 'package:sendrax/location/location_state.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/models/location_repo.dart';
import 'package:sendrax/models/user_repo.dart';

import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc(this.locationId);

  final String locationId;
  StreamSubscription<Location> locationSubscription;

  void _retrieveClimbsForThisLocation() async {
    add(ClearClimbsEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    if (user != null) {
      locationSubscription = LocationRepo.getInstance()
          .getClimbsForLocation(locationId, user)
          .listen((location) {
        add(ClimbsUpdatedEvent(
            location.climbs..sort((a, b) => a.section.compareTo(b.section))));
      });
    } else {
      add(LocationErrorEvent());
    }
  }

  @override
  LocationState get initialState {
    _retrieveClimbsForThisLocation();
    return LocationState.initial();
  }

  @override
  Stream<LocationState> mapEventToState(LocationEvent event) async* {
    if (event is ClearClimbsEvent) {
      yield LocationState.isLoading(true, LocationState.initial());
    } else if (event is ClimbsUpdatedEvent) {
      yield LocationState.isLoading(
          false, LocationState.climbs(event.climbs, state));
    } else if (event is LocationErrorEvent) {
      yield LocationState.isLoading(false, state);
    }
  }

  @override
  Future<void> close() {
    if (locationSubscription != null) {
      locationSubscription.cancel();
    }
    return super.close();
  }
}
