import 'package:flutter/widgets.dart';

class CreateGradeSetState {
  String name;
  List<String> grades;
  final GlobalKey<FormFieldState> itemInputKey;
  final GlobalKey<FormState> formKey;
  String errorMessage;

  // @formatter:off
  CreateGradeSetState._internal(
      this.name, this.grades, this.itemInputKey, this.formKey, this.errorMessage);

  factory CreateGradeSetState.initial() => CreateGradeSetState._internal(
      "", <String>[], new GlobalKey<FormFieldState>(), new GlobalKey<FormState>(), "");

  factory CreateGradeSetState.addGrade(String grade, CreateGradeSetState state) =>
      CreateGradeSetState._internal(state.name, state.grades..add(grade), state.itemInputKey,
          state.formKey, state.errorMessage);

  factory CreateGradeSetState.removeGrade(String grade, CreateGradeSetState state) =>
      CreateGradeSetState._internal(state.name, state.grades..remove(grade), state.itemInputKey,
          state.formKey, state.errorMessage);

  factory CreateGradeSetState.error(String errorMessage, CreateGradeSetState state) =>
      CreateGradeSetState._internal(
          state.name, state.grades, state.itemInputKey, state.formKey, errorMessage);
}
// @formatter:on
