import 'package:flutter/widgets.dart';

class LoginState {
  bool loading;
  bool isLogin;

  final GlobalKey<FormState> formKey;
  String username;
  String password;
  String errorMessage;

  LoginState._internal(this.loading, this.isLogin, this.formKey, this.username,
      this.password, this.errorMessage);

  factory LoginState.initial() =>
      LoginState._internal(false, true, new GlobalKey<FormState>(), "", "", "");

  factory LoginState.loading(bool loading, LoginState state) =>
      LoginState._internal(loading, state.isLogin, state.formKey,
          state.username, state.password, state.errorMessage);

  factory LoginState.isLogin(bool isLogin, LoginState state) =>
      LoginState._internal(state.loading, isLogin, state.formKey,
          state.username, state.password, state.errorMessage);

  factory LoginState.username(String email, LoginState state) =>
      LoginState._internal(state.loading, state.isLogin, state.formKey, email,
          state.password, state.errorMessage);

  factory LoginState.password(String password, LoginState state) =>
      LoginState._internal(state.loading, state.isLogin, state.formKey,
          state.username, password, state.errorMessage);

  factory LoginState.errorMessage(String errorMessage, LoginState state) =>
      LoginState._internal(state.loading, state.isLogin, state.formKey,
          state.username, state.password, errorMessage);
}
