import 'package:flutter/widgets.dart';
import 'package:sendrax/models/climb.dart';

class CreateClimbState {
  bool loading;
  bool isEdit;
  final GlobalKey<FormState> formKey;
  String id;
  String displayName;
  String locationId;
  String grade;
  String gradesId;
  List<String> availableGrades;
  String section;
  List<String> availableSections;
  List<String> categories;
  List<String> selectedCategories;
  String errorMessage;

  // @formatter:off
  CreateClimbState._internal(this.loading, this.isEdit, this.formKey, this.id, this.displayName,
      this.locationId, this.grade, this.gradesId, this.availableGrades, this.section,
      this.availableSections, this.categories, this.selectedCategories, this.errorMessage);

  factory CreateClimbState.initial(
      Climb climb, List<String> availableSections, List<String> categories, bool isEdit) =>
      CreateClimbState._internal(true, isEdit, new GlobalKey<FormState>(), climb.id,
          climb.displayName, climb.locationId, climb.grade, climb.gradesId, <String>[],
          climb.section, availableSections, categories, climb.categories, "");

  factory CreateClimbState.loading(bool loading, CreateClimbState state) =>
      CreateClimbState._internal(loading, state.isEdit, state.formKey, state.id, state.displayName,
          state.locationId, state.grade, state.gradesId, state.availableGrades, state.section,
          state.availableSections, state.categories, state.selectedCategories, state.errorMessage);

  factory CreateClimbState.updateGrades(
          bool loading, List<String> grades, CreateClimbState state) =>
      CreateClimbState._internal(loading, state.isEdit, state.formKey, state.id, state.displayName,
          state.locationId, state.grade, state.gradesId, grades, state.section,
          state.availableSections, state.categories, state.selectedCategories, state.errorMessage);

  factory CreateClimbState.updateCategories(
          bool loading, List<String> categories, CreateClimbState state) =>
      CreateClimbState._internal(loading, state.isEdit, state.formKey, state.id, state.displayName,
          state.locationId, state.grade, state.gradesId, state.availableGrades, state.section,
          state.availableSections, categories, state.selectedCategories, state.errorMessage);
}
// @formatter:on
