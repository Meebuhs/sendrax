class Attempt {
  Attempt(this.timestamp, this.sendType, this.categories, this.warmup,
      this.drills, this.notes);

  final DateTime timestamp;
  final String sendType;
  final List<String> categories;
  final bool warmup;
  final List<String> drills;
  final String notes;
}
