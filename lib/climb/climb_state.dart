import 'package:flutter/widgets.dart';
import 'package:sendrax/models/attempt.dart';

class ClimbState {
  bool loading;
  final GlobalKey<FormState> formKey;
  final TextEditingController notesInputController;
  List<Attempt> attempts;
  bool downclimbed;
  String notes;

  // @formatter:off
  ClimbState._internal(this.loading, this.formKey, this.notesInputController,
      this.attempts, this.downclimbed, this.notes);

  factory ClimbState.initial() => ClimbState._internal(true,
      GlobalKey<FormState>(), TextEditingController(), <Attempt>[], false, "");

  factory ClimbState.loading(bool loading, ClimbState state) =>
      ClimbState._internal(loading, state.formKey, state.notesInputController,
          state.attempts, state.downclimbed, state.notes);

  factory ClimbState.updateAttempts(
          bool loading, List<Attempt> attempts, ClimbState state) =>
      ClimbState._internal(loading, state.formKey, state.notesInputController,
          attempts, state.downclimbed, state.notes);

  factory ClimbState.toggleDownclimbed(bool downclimbed, ClimbState state) =>
      ClimbState._internal(state.loading, state.formKey,
          state.notesInputController, state.attempts, downclimbed, state.notes);
}
// @formatter:on
