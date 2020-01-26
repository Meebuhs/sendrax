import 'package:flutter/widgets.dart';
import 'package:sendrax/models/climb.dart';

class CreateClimbState {
  bool loading;
  final GlobalKey<FormState> formKey;
  String displayName;
  String grade;
  String gradesId;
  List<String> availableGrades;
  String section;
  List<String> selectedCategories;
  String errorMessage;

  // @formatter:off
  CreateClimbState._internal(
      this.loading, this.formKey, this.displayName, this.grade, this.gradesId, this.availableGrades,
      this.section, this.selectedCategories, this.errorMessage);

  factory CreateClimbState.initial(Climb climb) =>
      CreateClimbState._internal(true, new GlobalKey<FormState>(), climb.displayName, climb.grade,
          climb.gradesId, <String>[], climb.section, climb.categories, "");

  factory CreateClimbState.loading(bool loading, CreateClimbState state) =>
      CreateClimbState._internal(loading, state.formKey, state.displayName, state.grade,
          state.gradesId, state.availableGrades, state.section, state.selectedCategories,
          state.errorMessage);

  factory CreateClimbState.updateGrades(
          bool loading, List<String> grades, CreateClimbState state) =>
      CreateClimbState._internal(loading, state.formKey, state.displayName, state.grade,
          state.gradesId, grades, state.section, state.selectedCategories, state.errorMessage);
}
// @formatter:on
