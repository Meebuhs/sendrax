import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:sendrax/create_location/create_location_event.dart';
import 'package:sendrax/create_location/create_location_state.dart';
import 'package:sendrax/create_location/create_location_view.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/grade_repo.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/models/location_repo.dart';
import 'package:sendrax/models/user_repo.dart';
import 'package:sendrax/navigation_helper.dart';

class CreateLocationBloc extends Bloc<CreateLocationEvent, CreateLocationState> {
  CreateLocationBloc(this.location, this.isEdit);

  final Location location;
  final bool isEdit;

  StreamController sectionsStream = StreamController<List<String>>.broadcast();
  StreamSubscription<List<String>> gradesSubscription;
  StreamSubscription<Location> locationSubscription;

  @override
  CreateLocationState get initialState {
    if (isEdit) {
      _retrieveDataForThisLocation();
    }
    _retrieveAvailableGradeSets();
    return CreateLocationState.initial(location, isEdit);
  }

  void _retrieveAvailableGradeSets() async {
    add(GradesClearedEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    if (user != null) {
      gradesSubscription = GradeRepo.getInstance().getGradeIds(user).listen((grades) {
        add(GradesUpdatedEvent(grades));
      });
    } else {
      add(CreateLocationErrorEvent());
    }
  }

  void _retrieveDataForThisLocation() async {
    add(LocationClearedEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    if (user != null) {
      locationSubscription =
          LocationRepo.getInstance().getSectionsForLocation(location.id, user).listen((location) {
        add(LocationUpdatedEvent(location));
      });
    } else {
      add(CreateLocationErrorEvent());
    }
  }

  void validateAndSubmit(
      CreateLocationState state, BuildContext context, CreateLocationWidget view) async {
    FocusScope.of(context).unfocus();
    state.loading = true;

    if (_validateAndSave(state)) {
      Location location = new Location(this.location.id, state.displayName, state.gradesId,
          <String>[], state.sections, <Climb>[]);
      try {
        LocationRepo.getInstance().setLocation(location);
        state.loading = false;
      } catch (e) {
        state.formKey.currentState.reset();
        state.loading = false;
        add(CreateLocationErrorEvent());
      }
      view.navigateBackOne();
    }
    state.loading = false;
  }

  bool _validateAndSave(CreateLocationState state) {
    final form = state.formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void selectGrade(String grade) {
    add(GradeSelectedEvent(grade));
  }

  void setSectionsList(List<String> sections) {
    sectionsStream.stream.listen((sections) {
      state.sections = sections;
    });
  }

  void deleteLocation(String locationId, BuildContext context, CreateLocationWidget view) {
    LocationRepo.getInstance().deleteLocation(locationId);
    NavigationHelper.resetToMain(context);
  }

  @override
  Stream<CreateLocationState> mapEventToState(CreateLocationEvent event) async* {
    if (event is GradesClearedEvent) {
      yield CreateLocationState.updateGrades(true, <String>[], state);
    } else if (event is LocationClearedEvent) {
      yield CreateLocationState.updateLocation(true,
          new Location(this.location.id, state.displayName, state.gradesId, <String>[]), state);
    } else if (event is GradesUpdatedEvent) {
      yield CreateLocationState.updateGrades(false, event.availableGrades, state);
    } else if (event is LocationUpdatedEvent) {
      yield CreateLocationState.updateLocation(false, event.location, state);
    } else if (event is CreateLocationErrorEvent) {
      yield CreateLocationState.loading(false, state);
    } else if (event is GradeSelectedEvent) {
      yield CreateLocationState.selectGrade(event.grade, state);
    }
  }

  @override
  Future<void> close() {
    sectionsStream.close();
    if (gradesSubscription != null) {
      gradesSubscription.cancel();
    }
    if (locationSubscription != null) {
      locationSubscription.cancel();
    }
    return super.close();
  }
}
