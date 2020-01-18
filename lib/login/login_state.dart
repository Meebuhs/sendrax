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

  LoginState._internal(this.loading, this.isLogin, this.formKey, this.passwordKey, this.username,
      this.password, this.confirmPassword, this.errorMessage);

  factory LoginState.initial() =>
      LoginState._internal(
          false,
          true,
          new GlobalKey<FormState>(),
          new GlobalKey<FormFieldState>(),
          "",
          "",
          "",
          "");

  factory LoginState.loading(bool loading, LoginState state) =>
      LoginState._internal(
          loading,
          state.isLogin,
          state.formKey,
          state.passwordKey,
          state.username,
          state.password,
          state.confirmPassword,
          state.errorMessage);

  factory LoginState.isLogin(bool isLogin, LoginState state) =>
      LoginState._internal(
          state.loading,
          isLogin,
          state.formKey,
          state.passwordKey,
          state.username,
          state.password,
          state.confirmPassword,
          state.errorMessage);

  factory LoginState.username(String email, LoginState state) =>
      LoginState._internal(
          state.loading,
          state.isLogin,
          state.formKey,
          state.passwordKey,
          email,
          state.password,
          state.confirmPassword,
          state.errorMessage);

  factory LoginState.password(String password, LoginState state) =>
      LoginState._internal(
          state.loading,
          state.isLogin,
          state.formKey,
          state.passwordKey,
          state.username,
          password,
          state.confirmPassword,
          state.errorMessage);

  factory LoginState.confirmPassword(String confirmPassword, LoginState state) =>
      LoginState._internal(
          state.loading,
          state.isLogin,
          state.formKey,
          state.passwordKey,
          state.username,
          state.password,
          confirmPassword,
          state.errorMessage);

  factory LoginState.errorMessage(String errorMessage, LoginState state) =>
      LoginState._internal(
          state.loading,
          state.isLogin,
          state.formKey,
          state.passwordKey,
          state.username,
          state.password,
          state.confirmPassword,
          errorMessage);
}
