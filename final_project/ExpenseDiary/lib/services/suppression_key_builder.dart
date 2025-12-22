import '../models/unresolved_transaction.dart';

class SuppressionKeyBuilder {
  /// Most reliable: merchant-based
  static String fromTransaction(UnresolvedTransaction tx) {
    if (tx.merchantRaw.trim().isNotEmpty) {
      return 'merchant:${tx.merchantRaw.toLowerCase().trim()}';
    }

    // Fallback: amount bucket (very weak)
    final bucket = (tx.amount / 100).floor() * 100;
    return 'amount_bucket:$bucket';
  }
}
