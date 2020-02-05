import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:sendrax/models/grade_repo.dart';
import 'package:sendrax/models/gradeset.dart';
import 'package:sendrax/navigation_helper.dart';

import 'create_gradeset_event.dart';
import 'create_gradeset_state.dart';

class CreateGradeSetBloc extends Bloc<CreateGradeSetEvent, CreateGradeSetState> {
  @override
  CreateGradeSetState get initialState {
    return CreateGradeSetState.initial();
  }

  void addGrade(String grade) {
    if (grade.trim().isNotEmpty) {
      add(GradeAddedEvent(grade));
      state.itemInputKey.currentState.reset();
    }
  }

  void removeGrade(String grade) {
    add(GradeRemovedEvent(grade));
  }

  void createGradeSet(BuildContext context) async {
    if (_validateAndSave(state)) {
      GradeRepo.getInstance().setGradeSet(GradeSet(state.name, state.grades));
      NavigationHelper.navigateBackOne(context);
    }
  }

  bool _validateAndSave(CreateGradeSetState state) {
    final form = state.formKey.currentState;
    form.save();

    if (state.name.trim() == "") {
      add(GradeErrorEvent("Name can't be empty"));
      return false;
    } else if (state.grades.isEmpty) {
      add(GradeErrorEvent("Grades can't be empty"));
      return false;
    }
    return true;
  }

  @override
  Stream<CreateGradeSetState> mapEventToState(CreateGradeSetEvent event) async* {
    if (event is GradeAddedEvent) {
      yield CreateGradeSetState.addGrade(event.grade, state);
    } else if (event is GradeRemovedEvent) {
      yield CreateGradeSetState.removeGrade(event.grade, state);
    } else if (event is GradeErrorEvent) {
      yield CreateGradeSetState.error(event.errorMessage, state);
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
