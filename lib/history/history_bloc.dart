import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/attempt_repo.dart';
import 'package:sendrax/models/user.dart';
import 'package:sendrax/models/user_repo.dart';
import 'package:sendrax/util/constants.dart';

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
    final User user = await UserRepo.getInstance().getCurrentUser();
    _getRemainingAttemptsForBatch(
        await AttemptRepo.getInstance().getBatchOfAttempts(state.attempts, user).first, user, 0);
  }

  Future<void> refreshAttempts() async {
    final User user = await UserRepo.getInstance().getCurrentUser();
    _getRemainingAttemptsForBatch(
        await AttemptRepo.getInstance().getBatchOfAttempts(state.attempts, user).first, user, 0);
  }

  void retrieveMoreAttempts() async {
    int attemptsLength = state.attempts.length;
    final User user = await UserRepo.getInstance().getCurrentUser();
    _getRemainingAttemptsForBatch(
        await AttemptRepo.getInstance().getBatchOfAttempts(state.attempts, user).first,
        user,
        attemptsLength);
  }

  void _getRemainingAttemptsForBatch(List<Attempt> batch, User user, int attemptsLength) async {
    final List<Attempt> attempts =
        await AttemptRepo.getInstance().getRemainingAttemptsForBatch(batch, user).first;
    add(AttemptsUpdatedEvent(
        (attempts.length - attemptsLength < LazyLoadConstants.BATCH_SIZE), attempts));
  }

  @override
  Stream<HistoryState> mapEventToState(HistoryEvent event) async* {
    if (event is ClearAttemptsEvent) {
      yield HistoryState.updateAttempts(true, state.reachedEnd, <Attempt>[]);
    } else if (event is AttemptsUpdatedEvent) {
      yield HistoryState.updateAttempts(false, event.reachedEnd, event.attempts);
    } else if (event is HistoryErrorEvent) {
      yield HistoryState.updateAttempts(false, state.reachedEnd, state.attempts);
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
