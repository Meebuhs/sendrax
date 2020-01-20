import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

class CreateLocationState {
  bool loading;

  final GlobalKey<FormState> formKey;
  String id;
  String displayName;
  String errorMessage;
  final List<String> sections;
  String gradeId;
  var uuid = Uuid();

  CreateLocationState._internal(this.loading, this.formKey, this.id, this.displayName,
      this.sections, this.gradeId, this.errorMessage);

  factory CreateLocationState.initial() =>
      CreateLocationState._internal(
          false,
          new GlobalKey<FormState>(),
          "",
          "",
          <String>[],
          "",
          "");

  factory CreateLocationState.loading(bool loading, CreateLocationState state) =>
      CreateLocationState._internal(
          loading,
          state.formKey,
          state.id,
          state.displayName,
          state.sections,
          state.gradeId,
          state.errorMessage);

  factory CreateLocationState.id(String id, CreateLocationState state) =>
      CreateLocationState._internal(
          state.loading,
          state.formKey,
          id,
          state.displayName,
          state.sections,
          state.gradeId,
          state.errorMessage);

  factory CreateLocationState.displayName(String displayName, CreateLocationState state) =>
      CreateLocationState._internal(
          state.loading,
          state.formKey,
          state.id,
          displayName,
          state.sections,
          state.gradeId,
          state.errorMessage);

  factory CreateLocationState.sections(List<String> sections, CreateLocationState state) =>
      CreateLocationState._internal(
          state.loading,
          state.formKey,
          state.id,
          state.displayName,
          sections,
          state.gradeId,
          state.errorMessage);

  factory CreateLocationState.gradeId(String gradeId, CreateLocationState state) =>
      CreateLocationState._internal(
          state.loading,
          state.formKey,
          state.id,
          state.displayName,
          state.sections,
          gradeId,
          state.errorMessage);

  factory CreateLocationState.errorMessage(String errorMessage, CreateLocationState state) =>
      CreateLocationState._internal(
          state.loading,
          state.formKey,
          state.id,
          state.displayName,
          state.sections,
          state.gradeId,
          errorMessage);
}
