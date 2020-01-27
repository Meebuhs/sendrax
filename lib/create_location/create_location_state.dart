import 'package:flutter/widgets.dart';
import 'package:sendrax/models/location.dart';

class CreateLocationState {
  bool loading;
  final GlobalKey<FormState> formKey;
  String displayName;
  List<String> sections;
  String gradesId;
  List<String> availableGrades;
  String errorMessage;

  // @formatter:off
  CreateLocationState._internal(this.loading, this.formKey, this.displayName, this.sections,
      this.gradesId, this.availableGrades, this.errorMessage);

  factory CreateLocationState.initial(Location location, bool isEdit) =>
      CreateLocationState._internal(true, new GlobalKey<FormState>(), location.displayName,
          location.sections, location.gradesId, <String>[], "");

  factory CreateLocationState.loading(bool loading, CreateLocationState state) =>
      CreateLocationState._internal(loading, state.formKey, state.displayName, state.sections,
          state.gradesId, state.availableGrades, state.errorMessage);

  factory CreateLocationState.updateGrades(
          bool loading, List<String> availableGrades, CreateLocationState state) =>
      CreateLocationState._internal(loading, state.formKey, state.displayName, state.sections,
          state.gradesId, availableGrades, state.errorMessage);

  factory CreateLocationState.selectGrade(String grade, CreateLocationState state) =>
      CreateLocationState._internal(state.loading, state.formKey, state.displayName, state.sections,
          grade, state.availableGrades, state.errorMessage);

  factory CreateLocationState.updateLocation(
          bool loading, Location location, CreateLocationState state) =>
      CreateLocationState._internal(loading, state.formKey, state.displayName, location.sections,
          location.gradesId, state.availableGrades, state.errorMessage);
}
// @formatter:on
