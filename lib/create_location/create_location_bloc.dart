import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:sendrax/create_location/create_location_event.dart';
import 'package:sendrax/create_location/create_location_state.dart';

class CreateLocationBloc extends Bloc<CreateLocationEvent, CreateLocationState> {
  @override
  CreateLocationState get initialState => CreateLocationState.initial();

  @override
  Stream<CreateLocationState> mapEventToState(CreateLocationEvent event) async* {
    if (event is CreateLocationErrorEvent) {}
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
