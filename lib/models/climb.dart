import 'attempt.dart';

class Climb {
  Climb(this.id, this.displayName, this.imageURL, this.imageURI, this.locationId, this.grade,
      this.gradeSet, this.section, this.archived, this.sent, this.repeated, this.categories,
      [this.attempts]);

  final String id;
  final String displayName;
  final String imageURL;
  final String imageURI;
  final String locationId;
  final String grade;
  final String gradeSet;
  final String section;
  final bool archived;
  final bool sent;
  final bool repeated;
  final List<String> categories;
  final List<Attempt> attempts;

  Map<String, dynamic> get map {
    return {
      "id": id,
      "displayName": displayName,
      "imageUrl": imageURL,
      "imageUri": imageURI,
      "locationId": locationId,
      "grade": grade,
      "gradeSet": gradeSet,
      "section": section,
      "archived": archived,
      "sent": sent,
      "repeated": repeated,
      "categories": categories,
    };
  }
}
