class CreateLocationState {
  bool loading;
  String errorMessage;

  CreateLocationState._internal(this.loading, this.errorMessage);

  factory CreateLocationState.initial() => CreateLocationState._internal(true, "");

  factory CreateLocationState.loading(bool loading, CreateLocationState state) =>
      CreateLocationState._internal(loading, state.errorMessage);

  factory CreateLocationState.errorMessage(String errorMessage, CreateLocationState state) =>
      CreateLocationState._internal(state.loading, errorMessage);
}
