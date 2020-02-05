class ErrorMessages {
  static const String NO_USER_FOUND = "Login failed because there is no user in the database";
  static const String USER_TAKEN = "Signup failed because this user already exists";
}

class StorageKeys {
  static const String USER_ID_KEY = "user_id_key";
  static const String USER_DISPLAY_NAME_KEY = "display_name_key";
}

class UIConstants {
  // PADDING
  static const double SMALLER_PADDING = 8.0;
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
  static const String CLIMBS_SUBPATH = "climbs";
  static const String LOCATIONS_SUBPATH = "locations";
  static const String ATTEMPTS_SUBPATH = "attempts";
  static const String GRADES_SUBPATH = "grades";
  static const String CATEGORIES_SUBPATH = "categories";
}

// @formatter:off
class SendTypes {
  static const List<String> SEND_TYPES = const ["Onsight", "Flash", "Send", "Repeat", "Attempt",
    "Red Point", "Hang Dog", "Second", "Top Rope Onsight", "Top Rope Flash", "Top Rope",
    "Top Rope Solo Onsight", "Top Rope Solo Flash", "Top Sope Solo", "First Ascent"];
}

class ClimbCategories {
  static const List<String> CATEGORIES = const ["Crimps", "Edges", "Slopers", "Pinches", "Pockets",
    "Slopey Crimps", "Jugs", "Volumes", "Bad Feet", "Roof", "Overhung", "Slab", "Mantle", "Powerful",
    "Technical", "Sustained", "Compression", "Dyno", "Run and Jump", "Arete", "Dihedral"];
}
// @formatter:on