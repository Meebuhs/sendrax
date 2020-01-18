abstract class CreateLocationEvent {}

class CreateLocationErrorEvent extends CreateLocationEvent {
  CreateLocationErrorEvent(this.error);

  final dynamic error;
}
