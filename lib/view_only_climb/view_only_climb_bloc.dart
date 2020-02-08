import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/climb_repo.dart';
import 'package:sendrax/models/storage_repo.dart';
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
        Climb processedClimb;
        if (climb.imageUri != "") {
          final String url = await StorageRepo.getInstance().decodeUri(climb.imageUri);
          processedClimb = Climb(
              climb.id,
              climb.displayName,
              url,
              climb.imageUri,
              climb.locationId,
              climb.grade,
              climb.gradeSet,
              climb.section,
              climb.archived,
              climb.categories,
              climb.attempts);
        } else {
          processedClimb = climb;
        }
        ClimbRepo.getInstance().getAttemptsForClimb(processedClimb, user).listen((finalClimb) {
          add(ClimbUpdatedEvent(finalClimb));
        });
      });
    } else {
      add(ViewOnlyClimbErrorEvent());
    }
  }

  void unarchiveClimb(BuildContext context) {
    ClimbRepo.getInstance().setClimbArchived(climbId, false);
    NavigationHelper.navigateBackTwo(context);
  }

  void deleteClimb(BuildContext context) {
    ClimbRepo.getInstance().deleteClimb(climbId, state.climb.imageUri);
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
