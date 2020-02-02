import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:sendrax/location/location_event.dart';
import 'package:sendrax/location/location_state.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/grade_repo.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/models/location_repo.dart';
import 'package:sendrax/models/storage_repo.dart';
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
  StreamSubscription<List<String>> gradesSubscription;

  @override
  LocationState get initialState {
    _retrieveLocationData();
    return LocationState.initial();
  }

  void _retrieveLocationData() async {
    add(ClearDataEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    _retrieveClimbsForThisLocation(user);
    _retrieveSectionsForThisLocation(user);
    _retrieveGradesForThisLocation(user);
  }

  void _retrieveClimbsForThisLocation(User user) async {
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

  void _retrieveSectionsForThisLocation(User user) async {
    if (user != null) {
      Location newLocation = Location(location.id, location.displayName, location.imagePath,
          location.imageUri, location.gradeSet, categories, <String>[]);
      locationSubscription =
          LocationRepo.getInstance().getSectionsForLocation(newLocation, user).listen((location) {
        add(SectionsUpdatedEvent(location.sections));
      });
    } else {
      add(LocationErrorEvent());
    }
  }

  void _retrieveGradesForThisLocation(User user) async {
    if (user != null) {
      gradesSubscription =
          GradeRepo.getInstance().getGradesForId(user, location.gradeSet).listen((grades) {
        add(GradesUpdatedEvent(grades));
      });
    } else {
      add(LocationErrorEvent());
    }
  }

  void setGradeFilter(String grade) {
    add(GradeFilteredEvent(grade));
  }

  void setSectionFilter(String section) {
    add(SectionFilteredEvent(section));
  }

  @override
  Stream<LocationState> mapEventToState(LocationEvent event) async* {
    if (event is ClearDataEvent) {
      yield LocationState.clearData(true, state);
    } else if (event is ClimbsUpdatedEvent) {
      yield LocationState.updateClimbs(false, event.climbs, state);
    } else if (event is SectionsUpdatedEvent) {
      yield LocationState.updateSections(false, event.sections, state);
    } else if (event is GradesUpdatedEvent) {
      yield LocationState.updateGrades(false, event.grades, state);
    } else if (event is GradeFilteredEvent) {
      yield LocationState.setFilterGrade(event.filterGrade, state);
    } else if (event is SectionFilteredEvent) {
      yield LocationState.setFilterSection(event.filterSection, state);
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
    if (gradesSubscription != null) {
      gradesSubscription.cancel();
    }
    return super.close();
  }
}
