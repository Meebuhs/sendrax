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

  StreamController gradesIdStream = StreamController<String>();
  StreamController errorMessageStream = StreamController<String>();
  StreamController sectionsStream = StreamController<List<String>>.broadcast();
  StreamSubscription<List<String>> gradesSubscription;
  StreamSubscription<Location> locationSubscription;

  @override
  CreateLocationState get initialState {
    _retrieveAvailableGradeSets(isEdit);
    if (isEdit) {
      _retrieveDataForThisLocation();
    }
    return CreateLocationState.initial(location, isEdit);
  }

  void _retrieveAvailableGradeSets(bool isEdit) async {
    add(ClearGradesEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    if (user != null) {
      gradesSubscription = GradeRepo.getInstance().getGradeIds(user).listen((grades) {
        add(GradesUpdatedEvent(isEdit, grades));
      });
    } else {
      add(CreateLocationErrorEvent());
    }
  }

  void _retrieveDataForThisLocation() async {
    add(ClearLocationEvent());
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
    state.errorMessage = "";
    state.loading = true;

    if (_validateAndSave(state)) {
      Location location =
          new Location(state.id, state.displayName, state.gradesId, state.sections, <Climb>[]);
      try {
        LocationRepo.getInstance().setLocation(location);
        state.loading = false;
      } catch (e) {
        state.formKey.currentState.reset();
        state.loading = false;
        state.errorMessage = e.message;
        errorMessageStream.sink.add(state.errorMessage);
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
    state.gradesId = grade;
    gradesIdStream.add(grade);
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
    if (event is ClearGradesEvent) {
      yield CreateLocationState.updateGrades(true, <String>[], state);
    } else if (event is ClearLocationEvent) {
      yield CreateLocationState.updateLocation(
          true, new Location(state.id, state.displayName, state.gradesId), state);
    } else if (event is GradesUpdatedEvent) {
      yield CreateLocationState.updateGrades(event.isEdit, event.gradeIds, state);
    } else if (event is LocationUpdatedEvent) {
      yield CreateLocationState.updateLocation(false, event.location, state);
    } else if (event is CreateLocationErrorEvent) {
      yield CreateLocationState.loading(false, state);
    }
  }

  @override
  Future<void> close() {
    gradesIdStream.close();
    errorMessageStream.close();
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
