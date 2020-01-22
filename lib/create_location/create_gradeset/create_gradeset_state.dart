import 'package:flutter/widgets.dart';

class CreateGradeSetState {
  String name;
  List<String> itemList;
  final GlobalKey<FormFieldState> itemInputKey;
  final GlobalKey<FormState> formKey;
  String errorMessage;


  // @formatter:off
  CreateGradeSetState._internal(this.name, this.itemList, this.itemInputKey, this.formKey,
      this.errorMessage);

  factory CreateGradeSetState.initial() => CreateGradeSetState._internal(
      "", <String>[], new GlobalKey<FormFieldState>(), new GlobalKey<FormState>(), "");

  factory CreateGradeSetState.itemList(List<String> itemList, CreateGradeSetState state) =>
      CreateGradeSetState._internal(state.name, itemList, state.itemInputKey, state.formKey,
          state.errorMessage);
  }
// @formatter:on
