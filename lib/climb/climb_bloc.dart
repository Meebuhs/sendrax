import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:sendrax/climb/climb_view.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/attempt_repo.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/climb_repo.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/models/user_repo.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/util/constants.dart';
import 'package:uuid/uuid.dart';

import 'climb_event.dart';
import 'climb_state.dart';

class ClimbBloc extends Bloc<ClimbEvent, ClimbState> {
  ClimbBloc(this.climb);

  final Climb climb;
  final Uuid uuid = Uuid();
  StreamSubscription<List<Attempt>> climbSubscription;

  @override
  ClimbState get initialState {
    _retrieveAttemptsForThisClimb();
    return ClimbState.initial();
  }

  void _retrieveAttemptsForThisClimb() async {
    add(AttemptsClearedEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    if (user != null) {
      climbSubscription =
          ClimbRepo.getInstance().getAttemptsByClimbId(climb.id, user).listen((attempts) {
        // compare b to a so that the most recent attempt appears at the start of the list.
        add(AttemptsUpdatedEvent(attempts..sort((a, b) => b.timestamp.compareTo(a.timestamp))));
      });
    } else {
      add(ClimbErrorEvent());
    }
  }

  void selectSendType(String sendType) {
    add(SendTypeSelectedEvent(sendType));
  }

  void toggleDownclimbedCheckbox(bool downclimbed) {
    add(DownclimbedToggledEvent(downclimbed));
  }

  void validateAndSubmit(ClimbState state, BuildContext context) async {
    FocusScope.of(context).unfocus();
    state.loading = true;

    if (_validateAndSave(state)) {
      Attempt attempt = Attempt(
          "attempt-${uuid.v1()}",
          climb.id,
          climb.displayName,
          climb.grade,
          climb.gradeSet,
          climb.categories,
          climb.locationId,
          Timestamp.now(),
          state.sendType,
          state.downclimbed,
          state.notes);
      try {
        AttemptRepo.getInstance().setAttempt(attempt, climb);
        reconcileClimbStatus(climb);
        state.loading = false;
      } catch (e) {
        state.loading = false;
        add(ClimbErrorEvent());
      }
    }
    state.loading = false;
  }

  bool _validateAndSave(ClimbState state) {
    final form = state.formKey.currentState;
    if (form.validate()) {
      form.save();
      state.notes = state.notesInputController.text;
      return true;
    }
    return false;
  }

  void resetNotesInput() {
    WidgetsBinding.instance.addPostFrameCallback((_) => state.notesInputController.clear());
  }

  void reconcileClimbStatus(Climb climb) async {
    final user = await UserRepo.getInstance().getCurrentUser();
    List<Attempt> attempts =
    await ClimbRepo
        .getInstance()
        .getAttemptsByClimbId(climb.id, user)
        .first;
    print(attempts);
    bool sent = false;
    bool repeated = false;
    for (Attempt attempt in attempts) {
      if (SendTypes.SENDS.contains(attempt.sendType)) {
        sent = true;
      } else if (SendTypes.REPEATS.contains(attempt.sendType)) {
        repeated = true;
      }
    }
    ClimbRepo.getInstance().setClimbProperty(climb.id, "sent", sent);
    ClimbRepo.getInstance().setClimbProperty(climb.id, "repeated", repeated);
  }

  void archiveClimb(
      BuildContext context, ClimbWidget view, Location location, List<String> categories) {
    ClimbRepo.getInstance().setClimbProperty(this.climb.id, "archived", true);
    NavigationHelper.resetToLocation(context, location, categories);
  }

  void deleteClimb(
      BuildContext context, ClimbWidget view, Location location, List<String> categories) {
    ClimbRepo.getInstance().deleteClimb(this.climb.id, this.climb.imageURI);
    NavigationHelper.resetToLocation(context, location, categories);
  }

  @override
  Stream<ClimbState> mapEventToState(ClimbEvent event) async* {
    if (event is AttemptsClearedEvent) {
      yield ClimbState.updateAttempts(true, state.attempts, state);
    } else if (event is AttemptsUpdatedEvent) {
      yield ClimbState.updateAttempts(false, event.attempts, state);
    } else if (event is SendTypeSelectedEvent) {
      yield ClimbState.selectSendType(event.sendType, state);
    } else if (event is DownclimbedToggledEvent) {
      yield ClimbState.toggleDownclimbed(event.downclimbed, state);
    } else if (event is ClimbErrorEvent) {
      yield ClimbState.loading(false, state);
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
