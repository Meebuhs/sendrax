import 'package:flutter/widgets.dart';

class LoginState {
  bool loading;
  bool isLogin;

  final GlobalKey<FormState> formKey;
  final GlobalKey<FormFieldState> passwordKey;
  String username;
  String password;
  String confirmPassword;
  String errorMessage;

  // @formatter:off
  LoginState._internal(this.loading, this.isLogin, this.formKey, this.passwordKey, this.username,
      this.password, this.confirmPassword, this.errorMessage);

  factory LoginState.initial() => LoginState._internal(
      true, true, new GlobalKey<FormState>(), new GlobalKey<FormFieldState>(), "", "", "", "");

  factory LoginState.loading(bool loading, LoginState state) => LoginState._internal(
      loading,
      state.isLogin,
      state.formKey,
      state.passwordKey,
      state.username,
      state.password,
      state.confirmPassword,
      state.errorMessage);

  factory LoginState.toggleForm(LoginState state) => LoginState._internal(
      state.loading,
      !state.isLogin,
      state.formKey,
      state.passwordKey,
      state.username,
      state.password,
      state.confirmPassword,
      "");

  factory LoginState.error(String errorMessage, LoginState state) => LoginState._internal(
      false,
      state.isLogin,
      state.formKey,
      state.passwordKey,
      state.username,
      state.password,
      state.confirmPassword,
      errorMessage);
}
// @formatter:on
