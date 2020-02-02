import 'dart:io';

abstract class CreateClimbEvent {}

class GradeSelectedEvent extends CreateClimbEvent {
  GradeSelectedEvent(this.grade);

  final String grade;
}

class SectionSelectedEvent extends CreateClimbEvent {
  SectionSelectedEvent(this.section);

  final String section;
}

class CategoriesUpdatedEvent extends CreateClimbEvent {
  CategoriesUpdatedEvent(this.selectedCategories);

  final List<String> selectedCategories;
}

class ImageFileUpdatedEvent extends CreateClimbEvent {
  ImageFileUpdatedEvent(this.deleteImage, this.imageFile);

  final bool deleteImage;
  final File imageFile;
}

class CreateClimbErrorEvent extends CreateClimbEvent {}
