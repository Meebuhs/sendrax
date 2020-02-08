import 'package:sendrax/models/climb.dart';

class ViewOnlyClimbState {
  bool loading;
  Climb climb;

  // @formatter:off
  ViewOnlyClimbState._internal(this.loading, this.climb);

  factory ViewOnlyClimbState.initial() => ViewOnlyClimbState._internal(true, null);

  factory ViewOnlyClimbState.updateClimb(bool loading, Climb climb) =>
      ViewOnlyClimbState._internal(loading, climb);
}
// @formatter:on
