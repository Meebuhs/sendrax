import 'package:flutter/widgets.dart';
import 'package:sendrax/models/location.dart';

class CreateLocationState {
  bool loading;
  final GlobalKey<FormState> formKey;
  String displayName;
  List<String> sections;
  String gradeSet;
  List<String> grades;
  String errorMessage;

  // @formatter:off
  CreateLocationState._internal(this.loading, this.formKey, this.displayName, this.sections,
      this.gradeSet, this.grades, this.errorMessage);

  factory CreateLocationState.initial(Location location, bool isEdit) =>
      CreateLocationState._internal(true, new GlobalKey<FormState>(), location.displayName,
          location.sections, location.gradeSet, <String>[], "");

    factory CreateLocationState.loading(bool loading, CreateLocationState state) =>
      CreateLocationState._internal(loading, state.formKey, state.displayName, state.sections,
          state.gradeSet, state.grades, state.errorMessage);

  factory CreateLocationState.updateGrades(
          bool loading, List<String> grades, CreateLocationState state) =>
      CreateLocationState._internal(loading, state.formKey, state.displayName, state.sections,
          state.gradeSet, grades, state.errorMessage);

  factory CreateLocationState.selectGrade(String grade, CreateLocationState state) =>
      CreateLocationState._internal(state.loading, state.formKey, state.displayName, state.sections,
          grade, state.grades, state.errorMessage);

  factory CreateLocationState.updateLocation(
      bool loading, Location location, CreateLocationState state) =>
  CreateLocationState._internal(loading, state.formKey, state.displayName, location.sections,
      location.gradeSet, state.grades, state.errorMessage);
}
// @formatter:on
