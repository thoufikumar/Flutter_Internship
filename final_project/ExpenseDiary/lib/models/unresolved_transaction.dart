enum DetectionSource {
  sms,
  notification,
  manualMock, // for Phase 1 testing
}

enum UnresolvedStatus {
  pending,
  accepted,
  rejected,
}

class UnresolvedTransaction {
  final String id;
  final double amount;
  final DateTime dateTime;
  final String merchantRaw; // may be empty or noisy
  final DetectionSource source;
  UnresolvedStatus status;

  UnresolvedTransaction({
    required this.id,
    required this.amount,
    required this.dateTime,
    required this.merchantRaw,
    required this.source,
    this.status = UnresolvedStatus.pending,
  });
}
