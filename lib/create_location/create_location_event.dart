import 'dart:io';

import 'package:sendrax/models/location.dart';

abstract class CreateLocationEvent {}

class GradesClearedEvent extends CreateLocationEvent {}

class LocationClearedEvent extends CreateLocationEvent {}

class GradesUpdatedEvent extends CreateLocationEvent {
  GradesUpdatedEvent(this.grades);

  final List<String> grades;
}

class LocationUpdatedEvent extends CreateLocationEvent {
  LocationUpdatedEvent(this.location);

  final Location location;
}

class GradeSelectedEvent extends CreateLocationEvent {
  GradeSelectedEvent(this.grade);

  final String grade;
}

class ImageFileUpdatedEvent extends CreateLocationEvent {
  ImageFileUpdatedEvent(this.deleteImage, this.imageFile);

  final bool deleteImage;
  final File imageFile;
}

class CreateLocationErrorEvent extends CreateLocationEvent {}
