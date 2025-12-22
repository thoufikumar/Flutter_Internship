class ObservationRecord {
  final String key;
  final String message;
  final bool active;
  final DateTime detectedAt;

  ObservationRecord({
    required this.key,
    required this.message,
    required this.active,
    required this.detectedAt,
  });
}
