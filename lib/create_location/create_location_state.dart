import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:sendrax/models/location.dart';

class CreateLocationState {
  bool loading;
  final GlobalKey<FormState> formKey;
  String displayName;
  String existingImagePath;
  String existingImageUri;
  File newImageFile;
  bool deleteImage;
  List<String> sections;
  String gradeSet;
  List<String> grades;
  String errorMessage;

  // @formatter:off
  CreateLocationState._internal(this.loading, this.formKey, this.displayName,
      this.existingImagePath, this.existingImageUri, this.newImageFile, this.deleteImage,
      this.sections, this.gradeSet, this.grades, this.errorMessage);

  factory CreateLocationState.initial(Location location, bool isEdit) =>
      CreateLocationState._internal(true, new GlobalKey<FormState>(), location.displayName,
          location.imagePath, location.imageUri, null, false, location.sections, location.gradeSet,
          <String>[], "");

    factory CreateLocationState.loading(bool loading, CreateLocationState state) =>
      CreateLocationState._internal(loading, state.formKey, state.displayName,
          state.existingImagePath, state.existingImageUri, state.newImageFile, state.deleteImage,
          state.sections, state.gradeSet, state.grades, state.errorMessage);

  factory CreateLocationState.updateGrades(
          bool loading, List<String> grades, CreateLocationState state) =>
      CreateLocationState._internal(loading, state.formKey, state.displayName,
          state.existingImagePath, state.existingImageUri, state.newImageFile, state.deleteImage,
          state.sections, state.gradeSet, grades, state.errorMessage);

  factory CreateLocationState.selectGrade(String gradeSet, CreateLocationState state) =>
      CreateLocationState._internal(state.loading, state.formKey, state.displayName,
          state.existingImagePath, state.existingImageUri, state.newImageFile, state.deleteImage,
          state.sections, gradeSet, state.grades, state.errorMessage);

  factory CreateLocationState.updateLocation(
      bool loading, Location location, CreateLocationState state) =>
  CreateLocationState._internal(loading, state.formKey, state.displayName, location.imagePath,
      location.imageUri, state.newImageFile, state.deleteImage,  location.sections,
      location.gradeSet, state.grades, state.errorMessage);

  factory CreateLocationState.updateImageFile(
      bool deleteImage, File newImageFile, CreateLocationState state) =>
      CreateLocationState._internal(state.loading, state.formKey, state.displayName,
          state.existingImagePath, state.existingImageUri, newImageFile, deleteImage,
          state.sections, state.gradeSet, state.grades, state.errorMessage);

  factory CreateLocationState.updateImage(String path, String uri, CreateLocationState state) =>
      CreateLocationState._internal(state.loading, state.formKey, state.displayName, path,
          uri, state.newImageFile, false, state.sections, state.gradeSet, state.grades,
          state.errorMessage);

  factory CreateLocationState.clearImage(CreateLocationState state) =>
      CreateLocationState._internal(state.loading, state.formKey, state.displayName, "", "", null,
          state.deleteImage, state.sections, state.gradeSet, state.grades, state.errorMessage);
}
// @formatter:on
