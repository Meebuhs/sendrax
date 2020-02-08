import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:sendrax/models/user_repo.dart';

import 'log_event.dart';
import 'log_state.dart';

class LogBloc extends Bloc<LogEvent, LogState> {
  @override
  LogState get initialState {
    return LogState.initial();
  }

  void editCategories(List<String> categories) async {
    final user = await UserRepo.getInstance().getCurrentUser();
    UserRepo.getInstance().setUserCategories(user, categories);
  }

  @override
  Stream<LogState> mapEventToState(LogEvent event) async* {}
}
