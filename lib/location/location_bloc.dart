import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:sendrax/location/location_event.dart';
import 'package:sendrax/location/location_state.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/grade_repo.dart';
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
  StreamController filterGradeStream = StreamController<String>.broadcast();
  StreamController filterSectionStream = StreamController<String>.broadcast();
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
          LocationRepo.getInstance().getClimbsForLocation(location.id, user).listen((climbs) {
        add(ClimbsUpdatedEvent(climbs));
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

  void _retrieveGradesForThisLocation(User user) async {
    if (user != null) {
      gradesSubscription =
          GradeRepo.getInstance().getGradesForId(user, location.gradesId).listen((grades) {
        add(GradesUpdatedEvent(grades));
      });
    } else {
      add(LocationErrorEvent());
    }
  }

  void selectGrade(String grade) {
    state.filterGrade = grade;
    filterGradeStream.add(grade);
  }

  void selectSection(String section) {
    state.filterSection = section;
    filterSectionStream.add(section);
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
    } else if (event is LocationErrorEvent) {
      yield LocationState.loading(false, state);
    }
  }

  @override
  Future<void> close() {
    filterGradeStream.close();
    filterSectionStream.close();
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
