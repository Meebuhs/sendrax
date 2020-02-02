import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:sendrax/models/climb.dart';

class CreateClimbState {
  bool loading;
  final GlobalKey<FormState> formKey;
  String displayName;
  String imagePath;
  String imageUri;
  File imageFile;
  bool deleteImage;
  String grade;
  String gradeSet;
  List<String> grades;
  String section;
  List<String> selectedCategories;

  // @formatter:off
  CreateClimbState._internal(
      this.loading, this.formKey, this.displayName, this.imagePath, this.imageUri,
      this.imageFile, this.deleteImage, this.grade, this.gradeSet, this.grades, this.section,
      this.selectedCategories);

  factory CreateClimbState.initial(Climb climb, List<String> grades) =>
      CreateClimbState._internal(false, new GlobalKey<FormState>(), climb.displayName,
          climb.imagePath, climb.imageUri, null, false, climb.grade, climb.gradeSet, grades,
          climb.section, climb.categories);

  factory CreateClimbState.loading(bool loading, CreateClimbState state) =>
      CreateClimbState._internal(loading, state.formKey, state.displayName, state.imagePath,
          state.imageUri, state.imageFile, state.deleteImage, state.grade,
          state.gradeSet, state.grades, state.section, state.selectedCategories);

  factory CreateClimbState.selectGrade(String grade, CreateClimbState state) =>
      CreateClimbState._internal(state.loading, state.formKey, state.displayName,
          state.imagePath, state.imageUri, state.imageFile, state.deleteImage,
          grade, state.gradeSet, state.grades, state.section, state.selectedCategories);

  factory CreateClimbState.selectSection(String section, CreateClimbState state) =>
      CreateClimbState._internal(state.loading, state.formKey, state.displayName,
          state.imagePath, state.imageUri, state.imageFile, state.deleteImage,
          state.grade, state.gradeSet, state.grades, section, state.selectedCategories);

  factory CreateClimbState.updateCategories(List<String> selectedCategories, CreateClimbState state) =>
      CreateClimbState._internal(state.loading, state.formKey, state.displayName,
          state.imagePath, state.imageUri, state.imageFile, state.deleteImage,
          state.grade, state.gradeSet, state.grades, state.section, selectedCategories);

    factory CreateClimbState.updateImageFile(
        bool deleteImage, File imageFile, CreateClimbState state) =>
      CreateClimbState._internal(state.loading, state.formKey, state.displayName,
          state.imagePath, state.imageUri, imageFile, deleteImage,
          state.grade, state.gradeSet, state.grades, state.section, state.selectedCategories);
}
// @formatter:on
