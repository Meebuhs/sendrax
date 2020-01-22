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
    }
    view.navigateToMain();
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

  @override
  Stream<CreateLocationState> mapEventToState(CreateLocationEvent event) async* {
    if (event is ClearGradesEvent) {
      yield CreateLocationState.loading(true, <String>[], state);
    } else if (event is ClearLocationEvent) {
      yield CreateLocationState.location(true, new Location(state.id, state.displayName), state);
    } else if (event is GradesUpdatedEvent) {
      yield CreateLocationState.loading(event.isEdit, event.gradeIds, state);
    } else if (event is LocationUpdatedEvent) {
      yield CreateLocationState.location(false, event.location, state);
    } else if (event is CreateLocationErrorEvent) {
      yield CreateLocationState.loading(false, state.gradeIds, state);
    }
  }

  @override
  Future<void> close() {
    gradesIdStream.close();
    errorMessageStream.close();
    sectionsStream.close();
    gradesSubscription.cancel();
    locationSubscription.cancel();
    return super.close();
  }
}
