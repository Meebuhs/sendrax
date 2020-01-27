abstract class LoginEvent {}

class LoginWithEmailEvent extends LoginEvent {}

class LogoutEvent extends LoginEvent {}

class LoginEventInProgress extends LoginEvent {}

class LoginErrorEvent extends LoginEvent {
  LoginErrorEvent(this.errorMessage);

  final dynamic errorMessage;
}

class FormToggledEvent extends LoginEvent {}
