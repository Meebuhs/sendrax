class GradeSet {
  GradeSet(this.id, this.grades);

  final String id;
  final List<String> grades;

  Map<String, dynamic> get map {
    return {"id": id, "grades": grades};
  }
}
