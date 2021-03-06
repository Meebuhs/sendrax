import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:sendrax/models/location.dart';

class CreateLocationState {
  bool loading;
  final GlobalKey<FormState> formKey;
  String displayName;
  String imageUrl;
  String imageUri;
  File imageFile;
  bool deleteImage;
  List<String> sections;
  String gradeSet;
  List<String> gradeSets;
  String errorMessage;

  // @formatter:off
  CreateLocationState._internal(this.loading, this.formKey, this.displayName,
      this.imageUrl, this.imageUri, this.imageFile, this.deleteImage,
      this.sections, this.gradeSet, this.gradeSets, this.errorMessage);

  factory CreateLocationState.initial(Location location, bool isEdit) =>
      CreateLocationState._internal(true, GlobalKey<FormState>(), location.displayName,
          location.imageURL, location.imageURI, null, false, location.sections, location.gradeSet,
          <String>[], "");

    factory CreateLocationState.loading(bool loading, CreateLocationState state) =>
      CreateLocationState._internal(loading, state.formKey, state.displayName,
          state.imageUrl, state.imageUri, state.imageFile, state.deleteImage,
          state.sections, state.gradeSet, state.gradeSets, state.errorMessage);

  factory CreateLocationState.updateGradeSets(
          bool loading, List<String> gradeSets, CreateLocationState state) =>
      CreateLocationState._internal(loading, state.formKey, state.displayName,
          state.imageUrl, state.imageUri, state.imageFile, state.deleteImage,
          state.sections, state.gradeSet, gradeSets, state.errorMessage);

  factory CreateLocationState.selectGradeSet(String gradeSet, CreateLocationState state) =>
      CreateLocationState._internal(state.loading, state.formKey, state.displayName,
          state.imageUrl, state.imageUri, state.imageFile, state.deleteImage,
          state.sections, gradeSet, state.gradeSets, state.errorMessage);

  factory CreateLocationState.updateLocation(
      bool loading, Location location, CreateLocationState state) =>
  CreateLocationState._internal(loading, state.formKey, state.displayName, location.imageURL,
      location.imageURI, state.imageFile, state.deleteImage,  location.sections,
      location.gradeSet, state.gradeSets, state.errorMessage);

  factory CreateLocationState.updateImageFile(
      bool deleteImage, File imageFile, CreateLocationState state) =>
      CreateLocationState._internal(state.loading, state.formKey, state.displayName,
          state.imageUrl, state.imageUri, imageFile, deleteImage,
          state.sections, state.gradeSet, state.gradeSets, state.errorMessage);
}
// @formatter:on
