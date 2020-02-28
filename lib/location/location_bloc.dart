import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:sendrax/location/location_event.dart';
import 'package:sendrax/location/location_state.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/climb_repo.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/models/location_repo.dart';
import 'package:sendrax/models/storage_repo.dart';
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
        Stream<Climb> processedClimbsStream = Stream.fromIterable(climbs).asyncMap((climb) async {
          if (climb.imageUri != "") {
            final String url = await StorageRepo.getInstance().decodeUri(climb.imageUri);
            return Climb(
                climb.id,
                climb.displayName,
                url,
                climb.imageUri,
                climb.locationId,
                climb.grade,
                climb.gradeSet,
                climb.section,
                climb.archived,
                climb.categories,
                climb.attempts);
          } else {
            return climb;
          }
        });
        final List<Climb> processedClimbs = await processedClimbsStream.toList();
        add(ClimbsUpdatedEvent(processedClimbs));
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

  void setCategoryFilter(String grade) {
    add(CategoryFilteredEvent(grade));
  }

  void clearFilters() {
    add(FiltersClearedEvent());
  }

  void archiveSection(String section, BuildContext context) {
    for (Climb climb in location.climbs) {
      if (climb.section == section) {
        ClimbRepo.getInstance().setClimbArchived(climb.id, true);
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
