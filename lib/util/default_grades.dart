import 'package:sendrax/models/gradeset.dart';

// @formatter:off
class DefaultGrades {
  static final ewbanks = GradeSet("Ewbanks",
      ["12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26",
        "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39"]);
  static final yds = GradeSet("YDS",
      ["5.5", "5.6", "5.7", "5.8", "5.9", "5.10a", "5.10b", "5.10c", "5.10d", "5.11a", "5.11b",
        "5.11c", "5.11d", "5.12a", "5.12b", "5.12c", "5.12d", "5.13a", "5.13b", "5.13c", "5.13d",
        "5.14a", "5.14b", "5.14c", "5.14d", "5.15a", "5.15b", "5.15c", "5.15d"]);
  static final font = GradeSet("Font",
      ["5a", "5a+", "5b", "5b+", "5c", "5c+", "6a", "6a+", "6b", "6b+", "6c", "6c+", "7a", "7a+",
        "7b", "7b+", "7c", "7c+", "8a", "8a+", "8b", "8b+", "8c", "8c+", "9a", "9a+", "9b", "9b+",
        "9c"]);
  static final vScale = GradeSet("V Scale",
      ["VB", "V0", "V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10", "V11", "V12", "V13",
        "V14", "V15", "V16"]);
  static final french = GradeSet("French",
      ["4A", "4A+", "4B", "4B+", "4C", "4C+", "5A", "5A+", "5B", "5B+", "5C", "5C+", "6A", "6A+",
        "6B", "6B+", "6C", "6C+", "7A", "7A+", "7B", "7B+", "7C", "7C+", "8A", "8A+", "8B", "8B+",
        "8C", "8C+", "9A"]);
  static final defaultGrades = [ewbanks, yds, font, vScale, french];
}
// @formatter:on