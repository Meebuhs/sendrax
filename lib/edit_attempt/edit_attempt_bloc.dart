import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/attempt_repo.dart';

import 'edit_attempt_event.dart';
import 'edit_attempt_state.dart';

class EditAttemptBloc extends Bloc<EditAttemptEvent, EditAttemptState> {
  EditAttemptBloc(this.attempt);

  final Attempt attempt;

  @override
  EditAttemptState get initialState => EditAttemptState.initial(attempt);

  void selectSendType(String sendType) {
    add(SendTypeSelectedEvent(sendType));
  }

  void toggleDownclimbedCheckbox(bool downclimbed) {
    add(DownclimbedToggledEvent(downclimbed));
  }

  void editAttempt() {
    Attempt editedAttempt = Attempt(
        attempt.id,
        attempt.climbId,
        attempt.climbName,
        attempt.climbGrade,
        attempt.climbGradeSet,
        attempt.climbCategories,
        attempt.locationId,
        attempt.timestamp,
        state.sendType,
        state.downclimbed,
        state.notesInputController.value.text);
    AttemptRepo.getInstance().setAttempt(editedAttempt);
  }

  void resetNotesInput() {
    WidgetsBinding.instance.addPostFrameCallback((_) => state.notesInputController.clear());
  }

  @override
  Stream<EditAttemptState> mapEventToState(EditAttemptEvent event) async* {
    if (event is SendTypeSelectedEvent) {
      yield EditAttemptState.selectSendType(event.sendType, state);
    } else if (event is DownclimbedToggledEvent) {
      yield EditAttemptState.toggleDownclimbed(event.downclimbed, state);
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
