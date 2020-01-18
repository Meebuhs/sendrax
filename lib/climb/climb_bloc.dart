import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/climb_repo.dart';
import 'package:sendrax/models/user_repo.dart';

import 'climb_event.dart';
import 'climb_state.dart';

class ClimbBloc extends Bloc<ClimbEvent, ClimbState> {
  ClimbBloc(this.climbId);

  final String climbId;
  StreamSubscription<List<Attempt>> climbSubscription;

  void _retrieveAttemptsForThisClimb() async {
    add(ClearAttemptsEvent());
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

  @override
  ClimbState get initialState {
    _retrieveAttemptsForThisClimb();
    return ClimbState.initial();
  }

  @override
  Stream<ClimbState> mapEventToState(ClimbEvent event) async* {
    if (event is ClearAttemptsEvent) {
      yield ClimbState.isLoading(true, state.attempts, state);
    } else if (event is AttemptsUpdatedEvent) {
      yield ClimbState.isLoading(false, event.attempts, state);
    } else if (event is ClimbErrorEvent) {
      yield ClimbState.isLoading(false, state.attempts, state);
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
