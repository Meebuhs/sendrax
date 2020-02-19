import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:sendrax/models/functions_repo.dart';

import 'stats_event.dart';
import 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  @override
  StatsState get initialState {
    _retrieveCount();
    return StatsState.initial();
  }

  void _retrieveCount() async {
    int count = await FunctionsRepo.getInstance().countAttempts();
    add(CountUpdatedEvent(count));
  }

  @override
  Stream<StatsState> mapEventToState(StatsEvent event) async* {
    if (event is CountUpdatedEvent) {
      yield StatsState.updateCount(event.count, state);
    } else if (event is StatsErrorEvent) {
      yield StatsState.loading(false, state);
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
