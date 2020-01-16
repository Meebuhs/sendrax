import 'climb.dart';

class SelectedLocation {
  SelectedLocation(this.id, this.displayName);

  final String id;
  final String displayName;
}

class Location {
  Location(this.id, this.displayName, [this.climbs]);

  final String id;
  final String displayName;
  final List<Climb> climbs;
}
