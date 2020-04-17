import 'dart:ui';

class StorageKeys {
  static const String USER_ID_KEY = "user_id_key";
}

class UIConstants {
  // PADDING
  static const double SMALLER_PADDING = 8.0;
  static const double SMALL_PADDING = 12.0;
  static const double STANDARD_PADDING = 16.0;
  static const double BIGGER_PADDING = 24.0;

  // BORDER RADIUS
  static const double CARD_BORDER_RADIUS = 4.0;
  static const double FIELD_BORDER_RADIUS = 8.0;
  static const double BUTTON_BORDER_RADIUS = 8.0;
  static const double STANDARD_BORDER_RADIUS = 40.0;
}

class FirestorePaths {
  static const String ROOT_PATH = "";
  static const String USERS_COLLECTION = ROOT_PATH + "users";
  static const String USERNAMES_COLLECTION = ROOT_PATH + "usernames";
  static const String CLIMBS_SUBPATH = "climbs";
  static const String LOCATIONS_SUBPATH = "locations";
  static const String ATTEMPTS_SUBPATH = "attempts";
  static const String GRADES_SUBPATH = "grades";
  static const String CATEGORIES_SUBPATH = "categories";
}

class LazyLoadConstants {
  static const int DEBOUNCE_DURATION = 500;
  static const int SCROLL_OFFSET = 300;
  static const int BATCH_SIZE = 200;
}

class SeriesConstants {
  static const List<Color> COLOURS = const [
  Color(0xffff89b5),
  Color(0xffffdc89),
  Color(0xffcff381),
  Color(0xff90d4f7),
  Color(0xff898cff)
  ];

}

enum FilterType {
  gradeSet,
  grade,
  timeframe,
  location,
  sendType,
  category,
}

class TimeFrames {
  static const Map<String, String> TIME_FRAMES = const {
    "pastDay": "Past Day",
    "pastWeek": "Past Week",
    "pastMonth": "Past Month",
    "pastYear": "Past Year",
    "allTime": "All Time"
  };
}

class SendTypes {
  static const List<String> SEND_TYPES = const ["Onsight", "Flash", "Send", "Repeat", "Attempt"];
  static const List<String> SENDS = const ["Onsight", "Flash", "Send"];
  static const List<String> REPEATS = const ["Repeat"];
  static const List<String> CATEGORIES = const ["Not Sent", "Sent, Not Repeated", "Repeated"];
}

// @formatter:off
class ClimbCategories {
  static const List<String> CATEGORIES = const ["Crimps", "Edges", "Slopers", "Pinches", "Pockets",
    "Slopey Crimps", "Jugs", "Volumes", "Bad Feet", "Roof", "Overhung", "Slab", "Mantle", "Powerful",
    "Technical", "Sustained", "Compression", "Dyno", "Run and Jump", "Arete", "Dihedral"];
}
// @formatter:on