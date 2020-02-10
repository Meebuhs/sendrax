abstract class EditAttemptEvent {}

class SendTypeSelectedEvent extends EditAttemptEvent {
  SendTypeSelectedEvent(this.sendType);

  final String sendType;
}

class DownclimbedToggledEvent extends EditAttemptEvent {
  DownclimbedToggledEvent(this.downclimbed);

  final bool downclimbed;
}
