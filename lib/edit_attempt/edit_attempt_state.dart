import 'package:flutter/widgets.dart';
import 'package:sendrax/models/attempt.dart';

class EditAttemptState {
  final TextEditingController notesInputController;
  String sendType;
  bool downclimbed;

  // @formatter:off
  EditAttemptState._internal(this.notesInputController, this.sendType, this.downclimbed);

  factory EditAttemptState.initial(Attempt attempt) => EditAttemptState._internal(
      TextEditingController(text: attempt.notes), attempt.sendType, attempt.downclimbed);

  factory EditAttemptState.selectSendType(String sendType, EditAttemptState state) =>
      EditAttemptState._internal(state.notesInputController, sendType, state.downclimbed);

  factory EditAttemptState.toggleDownclimbed(bool downclimbed, EditAttemptState state) =>
      EditAttemptState._internal(state.notesInputController, state.sendType, downclimbed);
}
// @formatter:on
