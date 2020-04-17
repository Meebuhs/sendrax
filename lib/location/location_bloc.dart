import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:sendrax/location/location_event.dart';
import 'package:sendrax/location/location_state.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/climb_repo.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/models/location_repo.dart';
import 'package:sendrax/models/user_repo.dart';
import 'package:sendrax/navigation_helper.dart';

import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc(this.location, this.categories);

  final Location location;
  final List<String> categories;
  StreamSubscription<List<Climb>> climbSubscription;

  @override
  LocationState get initialState {
    _retrieveClimbsForThisLocation();
    return LocationState.initial();
  }

  void _retrieveClimbsForThisLocation() async {
    final user = await UserRepo.getInstance().getCurrentUser();

    if (user != null) {
      climbSubscription =
          LocationRepo.getInstance().getClimbsForLocation(location.id, user).listen((climbs) async {
            add(ClimbsUpdatedEvent(climbs));
      });
    } else {
      add(LocationErrorEvent());
    }
  }

  void setSectionFilter(String section) {
    add(SectionFilteredEvent(section));
  }

  void setGradeFilter(String grade) {
    add(GradeFilteredEvent(grade));
  }

  void setStatusFilter(String status) {
    add(StatusFilteredEvent(status));
  }

  void setCategoryFilter(String category) {
    add(CategoryFilteredEvent(category));
  }

  void clearFilters() {
    add(FiltersClearedEvent());
  }

  void archiveSection(String section, BuildContext context) {
    for (Climb climb in state.climbs) {
      if (climb.section == section) {
        ClimbRepo.getInstance().setClimbProperty(climb.id, "archived", true);
      }
    }
    NavigationHelper.navigateBackOne(context);
    add(ClimbsUpdatedEvent(location.climbs..retainWhere((climb) => climb.section != section)));
  }

  @override
  Stream<LocationState> mapEventToState(LocationEvent event) async* {
    if (event is ClearDataEvent) {
      yield LocationState.clearData(true, state);
    } else if (event is ClimbsUpdatedEvent) {
      yield LocationState.updateClimbs(false, event.climbs, state);
    } else if (event is SectionFilteredEvent) {
      yield LocationState.setFilterSection(event.filterSection, state);
    } else if (event is GradeFilteredEvent) {
      yield LocationState.setFilterGrade(event.filterGrade, state);
    } else if (event is StatusFilteredEvent) {
      yield LocationState.setFilterStatus(event.filterStatus, state);
    } else if (event is CategoryFilteredEvent) {
      yield LocationState.setFilterCategory(event.filterCategory, state);
    } else if (event is FiltersClearedEvent) {
      yield LocationState.clearFilters(state);
    } else if (event is LocationErrorEvent) {
      yield LocationState.loading(false, state);
    }
  }

  @override
  Future<void> close() {
    if (climbSubscription != null) {
      climbSubscription.cancel();
    }
    return super.close();
  }
}
