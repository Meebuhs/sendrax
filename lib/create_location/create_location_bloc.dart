import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:sendrax/create_location/create_location_event.dart';
import 'package:sendrax/create_location/create_location_state.dart';
import 'package:sendrax/create_location/create_location_view.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/models/location_repo.dart';
import 'package:uuid/uuid.dart';

class CreateLocationBloc extends Bloc<CreateLocationEvent, CreateLocationState> {
  StreamController gradeIdStream = StreamController<String>();
  StreamController errorMessageStream = StreamController<String>();
  var uuid = new Uuid();

  @override
  CreateLocationState get initialState => CreateLocationState.initial();

  void validateAndSubmit(CreateLocationState state, BuildContext context,
      CreateLocationWidget view) async {
    FocusScope.of(context).unfocus();
    state.errorMessage = "";
    state.loading = true;

    if (validateAndSave(state)) {
      Location location = new Location(
          "location-${uuid.v1()}", state.displayName, state.gradeId, state.sections, <Climb>[]);
      try {
        await LocationRepo.getInstance().setLocation(location);
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

  bool validateAndSave(CreateLocationState state) {
    final form = state.formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void selectGrade(String grade) {
    state.gradeId = grade;
    gradeIdStream.add(grade);
  }

  @override
  Stream<CreateLocationState> mapEventToState(CreateLocationEvent event) async* {
    if (event is CreateLocationErrorEvent) {}
  }

  @override
  Future<void> close() {
    gradeIdStream.close();
    errorMessageStream.close();
    return super.close();
  }
}
