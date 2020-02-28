import 'climb.dart';

class Location {
  Location(this.id, this.displayName, this.imageURL, this.imageURI, this.gradeSet,
      [this.grades, this.sections, this.climbs]);

  final String id;
  final String displayName;
  final String imageURL;
  final String imageURI;
  final String gradeSet;
  final List<String> grades;
  final List<String> sections;
  final List<Climb> climbs;

  Map<String, dynamic> get map {
    return {
      "id": id,
      "displayName": displayName,
      "imageUrl": imageURL,
      "imageUri": imageURI,
      "gradeSet": gradeSet,
      "grades": grades,
      "sections": sections,
    };
  }
}
