import 'package:flutter/widgets.dart';
import 'package:sendrax/models/location.dart';

class CreateLocationState {
  bool loading;
  bool isEdit;
  final GlobalKey<FormState> formKey;
  String id;
  String displayName;
  List<String> sections;
  String gradesId;
  List<String> gradeIds;
  String errorMessage;

  // @formatter:off
  CreateLocationState._internal(this.loading, this.isEdit, this.formKey, this.id, this.displayName,
      this.sections, this.gradesId, this.gradeIds, this.errorMessage);

  factory CreateLocationState.initial(Location location, bool isEdit) =>
      CreateLocationState._internal(true, isEdit, new GlobalKey<FormState>(), location.id,
          location.displayName, location.sections, location.gradesId, <String>[], "");

  factory CreateLocationState.loading(
          bool loading, List<String> availableGradeSets, CreateLocationState state) =>
      CreateLocationState._internal(loading, state.isEdit, state.formKey, state.id,
          state.displayName, state.sections, state.gradesId, availableGradeSets,
          state.errorMessage);

  factory CreateLocationState.location(bool loading, Location location, CreateLocationState state) =>
  CreateLocationState._internal(loading, state.isEdit, state.formKey, state.id,
          state.displayName, location.sections, location.gradesId, state.gradeIds,
          state.errorMessage);

  factory CreateLocationState.displayName(String displayName, CreateLocationState state) =>
      CreateLocationState._internal(state.loading, state.isEdit, state.formKey, state.id,
          displayName, state.sections, state.gradesId, state.gradeIds, state.errorMessage);

  factory CreateLocationState.sections(List<String> sections, CreateLocationState state) =>
      CreateLocationState._internal(state.loading, state.isEdit, state.formKey, state.id,
          state.displayName, sections, state.gradesId, state.gradeIds, state.errorMessage);

  factory CreateLocationState.gradesId(String gradeId, CreateLocationState state) =>
      CreateLocationState._internal(state.loading, state.isEdit, state.formKey, state.id,
          state.displayName, state.sections, gradeId, state.gradeIds, state.errorMessage);

  factory CreateLocationState.gradeIds(
          List<String> availableGradeSets, CreateLocationState state) =>
      CreateLocationState._internal(state.loading, state.isEdit, state.formKey, state.id,
          state.displayName, state.sections, state.gradesId, availableGradeSets,
          state.errorMessage);

  factory CreateLocationState.errorMessage(String errorMessage, CreateLocationState state) =>
      CreateLocationState._internal(state.loading, state.isEdit, state.formKey, state.id,
          state.displayName, state.sections, state.gradesId, state.gradeIds, errorMessage);
}
// @formatter:on
