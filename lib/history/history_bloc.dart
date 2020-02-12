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
    add(AttemptsLoadingEvent());
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

  void setGradeFilter(String grade) {
    add(GradeFilteredEvent(grade));
  }

  void setLocationFilter(String location) {
    add(LocationFilteredEvent(location));
  }

  void setCategoryFilter(String category) {
    add(CategoryFilteredEvent(category));
  }

  void clearFilters() {
    add(FiltersClearedEvent());
  }

  @override
  Stream<HistoryState> mapEventToState(HistoryEvent event) async* {
    if (event is ClearAttemptsEvent) {
      yield HistoryState.clearAttempts(state);
    } else if (event is AttemptsLoadingEvent) {
      yield HistoryState.loading(false, true, state);
    } else if (event is AttemptsUpdatedEvent) {
      yield HistoryState.updateAttempts(event.reachedEnd, event.attempts, state);
    } else if (event is FiltersClearedEvent) {
      yield HistoryState.clearFilters(state);
    } else if (event is GradeFilteredEvent) {
      yield HistoryState.setFilterGrade(event.filterGrade, state);
    } else if (event is LocationFilteredEvent) {
      yield HistoryState.setFilterLocation(event.filterLocation, state);
    } else if (event is CategoryFilteredEvent) {
      yield HistoryState.setFilterCategory(event.filterCategory, state);
    } else if (event is HistoryErrorEvent) {
      yield HistoryState.loading(false, false, state);
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
