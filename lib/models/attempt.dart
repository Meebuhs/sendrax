class Attempt {
  Attempt(this.timestamp, this.sendType, this.warmup,
      this.drills, this.notes);

  final DateTime timestamp;
  final String sendType;
  final bool warmup;
  final List<String> drills;
  final String notes;
}
