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

  // @formatter:off
  CreateClimbState._internal(
      this.loading, this.formKey, this.displayName, this.grade, this.gradesId, this.availableGrades,
      this.section, this.selectedCategories);

  factory CreateClimbState.initial(Climb climb, List<String> availableGrades) =>
      CreateClimbState._internal(false, new GlobalKey<FormState>(), climb.displayName, climb.grade,
          climb.gradesId, availableGrades, climb.section, climb.categories);

  factory CreateClimbState.loading(bool loading, CreateClimbState state) =>
      CreateClimbState._internal(loading, state.formKey, state.displayName, state.grade,
          state.gradesId, state.availableGrades, state.section, state.selectedCategories);

  factory CreateClimbState.selectGrade(String grade, CreateClimbState state) =>
      CreateClimbState._internal(state.loading, state.formKey, state.displayName, grade,
          state.gradesId, state.availableGrades, state.section, state.selectedCategories);

  factory CreateClimbState.selectSection(String section, CreateClimbState state) =>
      CreateClimbState._internal(state.loading, state.formKey, state.displayName, state.grade,
          state.gradesId, state.availableGrades, section, state.selectedCategories);

  factory CreateClimbState.updateCategories(List<String> selectedCategories, CreateClimbState state) =>
      CreateClimbState._internal(state.loading, state.formKey, state.displayName, state.grade,
          state.gradesId, state.availableGrades, state.section, selectedCategories);
}
// @formatter:on
