import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/climb_repo.dart';
import 'package:sendrax/models/user_repo.dart';
import 'package:uuid/uuid.dart';

import 'climb_event.dart';
import 'climb_state.dart';

class ClimbBloc extends Bloc<ClimbEvent, ClimbState> {
  ClimbBloc(this.climbId);

  final String climbId;
  final Uuid uuid = Uuid();
  StreamSubscription<List<Attempt>> climbSubscription;

  @override
  ClimbState get initialState {
    _retrieveAttemptsForThisClimb();
    return ClimbState.initial();
  }

  void _retrieveAttemptsForThisClimb() async {
    add(AttempsClearedEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    if (user != null) {
      climbSubscription =
          ClimbRepo.getInstance().getAttemptsForClimb(climbId, user).listen((attempts) {
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

  void toggleWarmupCheckbox(bool warmup) {
    add(WarmupToggledEvent(warmup));
  }

  void toggleDownclimbedCheckbox(bool downclimbed) {
    add(DownclimbedToggledEvent(downclimbed));
  }

  void validateAndSubmit(ClimbState state, BuildContext context) async {
    FocusScope.of(context).unfocus();
    state.loading = true;

    if (_validateAndSave(state)) {
      Attempt attempt = new Attempt("attempt-${uuid.v1()}", new Timestamp.now(), state.sendType,
          state.warmup, state.downclimbed, state.notes);
      try {
        ClimbRepo.getInstance().setAttempt(attempt, climbId);
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

  @override
  Stream<ClimbState> mapEventToState(ClimbEvent event) async* {
    if (event is AttempsClearedEvent) {
      yield ClimbState.updateAttempts(true, state.attempts, state);
    } else if (event is AttemptsUpdatedEvent) {
      yield ClimbState.updateAttempts(false, event.attempts, state);
    } else if (event is SendTypeSelectedEvent) {
      yield ClimbState.selectSendType(event.sendType, state);
    } else if (event is WarmupToggledEvent) {
      yield ClimbState.toggleWarmup(event.warmup, state);
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
