import 'dart:io';

import 'package:sendrax/models/location.dart';

abstract class CreateLocationEvent {}

class GradesClearedEvent extends CreateLocationEvent {}

class LocationClearedEvent extends CreateLocationEvent {}

class GradeSetsUpdatedEvent extends CreateLocationEvent {
  GradeSetsUpdatedEvent(this.gradeSets);

  final List<String> gradeSets;
}

class LocationUpdatedEvent extends CreateLocationEvent {
  LocationUpdatedEvent(this.location);

  final Location location;
}

class GradeSelectedEvent extends CreateLocationEvent {
  GradeSelectedEvent(this.gradeSet);

  final String gradeSet;
}

class ImageFileUpdatedEvent extends CreateLocationEvent {
  ImageFileUpdatedEvent(this.deleteImage, this.imageFile);

  final bool deleteImage;
  final File imageFile;
}

class CreateLocationErrorEvent extends CreateLocationEvent {}
