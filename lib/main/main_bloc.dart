import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:sendrax/models/login_repo.dart';

import 'main_event.dart';
import 'main_state.dart';
import 'main_view.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  void logout(MainWidget view) {
    LoginRepo.getInstance().signOut().then((success) {
      if (success) {
        view.navigateToLogin();
      }
    });
  }

  @override
  MainState get initialState {
    return MainState.initial();
  }

  @override
  Stream<MainState> mapEventToState(MainEvent event) async* {
    if (event is LocationsUpdatedEvent) {
      yield MainState.isLoading(
          false, MainState.locations(event.locations, state));
    } else if (event is MainErrorEvent) {
      yield MainState.isLoading(false, state);
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
