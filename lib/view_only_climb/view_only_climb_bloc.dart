import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/climb_repo.dart';
import 'package:sendrax/models/user_repo.dart';
import 'package:sendrax/navigation_helper.dart';

import 'view_only_climb_event.dart';
import 'view_only_climb_state.dart';

class ViewOnlyClimbBloc extends Bloc<ViewOnlyClimbEvent, ViewOnlyClimbState> {
  ViewOnlyClimbBloc(this.climbId);

  final String climbId;
  StreamSubscription<Climb> climbSubscription;

  @override
  ViewOnlyClimbState get initialState {
    _retrieveAttemptsForThisClimb();
    return ViewOnlyClimbState.initial();
  }

  void _retrieveAttemptsForThisClimb() async {
    add(ClimbClearedEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    if (user != null) {
      climbSubscription =
          ClimbRepo.getInstance().getClimbFromId(climbId, user).listen((climb) async {
            ClimbRepo.getInstance().getAttemptsForClimb(climb, user).listen((finalClimb) {
          add(ClimbUpdatedEvent(finalClimb));
        });
      });
    } else {
      add(ViewOnlyClimbErrorEvent());
    }
  }

  void unarchiveClimb(BuildContext context) {
    ClimbRepo.getInstance().setClimbProperty(climbId, "archived", false);
    NavigationHelper.navigateBackTwo(context);
  }

  void deleteClimb(BuildContext context) {
    ClimbRepo.getInstance().deleteClimb(climbId, state.climb.imageURI);
    NavigationHelper.navigateBackTwo(context);
  }

  @override
  Stream<ViewOnlyClimbState> mapEventToState(ViewOnlyClimbEvent event) async* {
    if (event is ClimbClearedEvent) {
      yield ViewOnlyClimbState.updateClimb(true, null);
    } else if (event is ClimbUpdatedEvent) {
      yield ViewOnlyClimbState.updateClimb(false, event.climb);
    } else if (event is ViewOnlyClimbErrorEvent) {
      yield ViewOnlyClimbState.updateClimb(false, state.climb);
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
