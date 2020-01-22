import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/climb_repo.dart';
import 'package:sendrax/models/grade_repo.dart';
import 'package:sendrax/models/user_repo.dart';

import 'create_climb_event.dart';
import 'create_climb_state.dart';
import 'create_climb_view.dart';

class CreateClimbBloc extends Bloc<CreateClimbEvent, CreateClimbState> {
  CreateClimbBloc(this.climb, this.availableSections, this.isEdit);

  final Climb climb;
  final List<String> availableSections;
  final bool isEdit;

  StreamController gradeStream = StreamController<String>();
  StreamController sectionStream = StreamController<String>();
  StreamController errorMessageStream = StreamController<String>();
  StreamSubscription<List<String>> gradesSubscription;

  @override
  CreateClimbState get initialState {
    _retrieveGrades(climb.gradesId);
    return CreateClimbState.initial(climb, availableSections, isEdit);
  }

  void _retrieveGrades(String gradesId) async {
    add(ClearGradesEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    if (user != null) {
      gradesSubscription = GradeRepo.getInstance().getGradesForId(user, gradesId).listen((grades) {
        add(GradesUpdatedEvent(grades));
      });
    } else {
      add(CreateClimbErrorEvent());
    }
  }

  void validateAndSubmit(
      CreateClimbState state, BuildContext context, CreateClimbWidget view) async {
    FocusScope.of(context).unfocus();
    state.errorMessage = "";
    state.loading = true;

    if (_validateAndSave(state)) {
      Climb climb = new Climb(state.id, state.displayName, state.locationId, state.grade,
          state.gradesId, state.section, false, state.categories, <Attempt>[]);
      try {
        ClimbRepo.getInstance().setClimb(climb);
        state.loading = false;
      } catch (e) {
        state.formKey.currentState.reset();
        state.loading = false;
        state.errorMessage = e.message;
        errorMessageStream.sink.add(state.errorMessage);
      }
      view.navigateToLocation();
    }
    state.loading = false;
  }

  bool _validateAndSave(CreateClimbState state) {
    final form = state.formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void selectGrade(String grade) {
    state.grade = grade;
    gradeStream.add(grade);
  }

  void selectSection(String section) {
    state.section = section;
    sectionStream.add(section);
  }

  @override
  Stream<CreateClimbState> mapEventToState(CreateClimbEvent event) async* {
    if (event is ClearGradesEvent) {
      yield CreateClimbState.updateGrades(true, <String>[], state);
    } else if (event is GradesUpdatedEvent) {
      yield CreateClimbState.updateGrades(false, event.grades, state);
    } else if (event is CreateClimbErrorEvent) {
      yield CreateClimbState.loading(false, state);
    }
  }

  @override
  Future<void> close() {
    gradeStream.close();
    sectionStream.close();
    errorMessageStream.close();
    if (gradesSubscription != null) {
      gradesSubscription.cancel();
    }
    return super.close();
  }
}
