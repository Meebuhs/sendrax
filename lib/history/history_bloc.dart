import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/attempt_repo.dart';
import 'package:sendrax/models/user_repo.dart';

import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  StreamSubscription<List<Attempt>> attemptsSubscription;

  @override
  HistoryState get initialState {
    _retrieveAttempts();
    return HistoryState.initial();
  }

  void _retrieveAttempts() async {
    add(ClearAttemptsEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    attemptsSubscription = AttemptRepo.getInstance().getAttempts(user).listen((attempts) {
      add(AttemptsUpdatedEvent(attempts));
    });
  }

  @override
  Stream<HistoryState> mapEventToState(HistoryEvent event) async* {
    if (event is ClearAttemptsEvent) {
      yield HistoryState.updateAttempts(true, <Attempt>[]);
    } else if (event is AttemptsUpdatedEvent) {
      yield HistoryState.updateAttempts(false, event.attempts);
    } else if (event is HistoryErrorEvent) {
      yield HistoryState.loading(false, state);
    }
  }

  @override
  Future<void> close() {
    if (attemptsSubscription != null) {
      attemptsSubscription.cancel();
    }
    return super.close();
  }
}
