import 'package:flutter/widgets.dart';
import 'package:sendrax/models/attempt.dart';

class ClimbState {
  bool loading;
  final GlobalKey<FormState> formKey;
  final TextEditingController notesInputController;
  List<Attempt> attempts;
  String sendType;
  bool downclimbed;
  String notes;

  // @formatter:off
  ClimbState._internal(
      this.loading, this.formKey, this.notesInputController, this.attempts, this.sendType,
      this.downclimbed, this.notes);

  factory ClimbState.initial() =>
      ClimbState._internal(true, GlobalKey<FormState>(), TextEditingController(),
          <Attempt>[], null, false, "");

  factory ClimbState.loading(bool loading, ClimbState state) => ClimbState._internal(
      loading, state.formKey, state.notesInputController, state.attempts, state.sendType,
          state.downclimbed, state.notes);

  factory ClimbState.updateAttempts(bool loading, List<Attempt> attempts, ClimbState state) =>
      ClimbState._internal(
      loading, state.formKey, state.notesInputController, attempts, state.sendType,
          state.downclimbed, state.notes);

  factory ClimbState.selectSendType(String sendType, ClimbState state) =>
      ClimbState._internal(
      state.loading, state.formKey, state.notesInputController, state.attempts, sendType,
          state.downclimbed, state.notes);

  factory ClimbState.toggleDownclimbed(bool downclimbed, ClimbState state) => ClimbState._internal(
      state.loading, state.formKey, state.notesInputController, state.attempts, state.sendType,
          downclimbed, state.notes);
}
// @formatter:on

