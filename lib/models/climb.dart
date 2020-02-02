import 'attempt.dart';

class Climb {
  Climb(this.id, this.displayName, this.imagePath, this.imageUri, this.locationId, this.grade,
      this.gradeSet, this.section, this.archived, this.categories,
      [this.attempts]);

  final String id;
  final String displayName;
  final String imagePath;
  final String imageUri;
  final String locationId;
  final String grade;
  final String gradeSet;
  final String section;
  final bool archived;
  final List<String> categories;
  final List<Attempt> attempts;

  Map<String, dynamic> get map {
    return {
      "id": id,
      "displayName": displayName,
      "imageUri": imageUri,
      "locationId": locationId,
      "grade": grade,
      "gradeSet": gradeSet,
      "section": section,
      "archived": archived,
      "categories": categories,
    };
  }
}
