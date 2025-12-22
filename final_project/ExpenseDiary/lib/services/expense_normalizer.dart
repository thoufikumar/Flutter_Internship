import '../models/unresolved_transaction.dart';
import 'merchant_key_normalizer.dart';
import 'merchant_memory_store.dart';

class ExpenseNormalizer {
  final MerchantMemoryStore _memory = MerchantMemoryStore();

  Future<Map<String, dynamic>> normalizeFromUnresolved(
    UnresolvedTransaction tx,
  ) async {
    final merchantKey =
        MerchantKeyNormalizer.normalize(tx.merchantRaw);

    final rememberedTitle =
        await _memory.getTitle(merchantKey);

    final title = rememberedTitle ??
        (tx.merchantRaw.isEmpty
            ? 'Unknown expense'
            : tx.merchantRaw);

    return {
      'title': title,
      'amount': tx.amount,
      'date': tx.dateTime.toIso8601String(),
      'source': 'auto',
      'merchantKey': merchantKey,
    };
  }

  /// Call this AFTER user confirms (Accept or Edit)
  Future<void> learnFromExpense(
    Map<String, dynamic> expense,
  ) async {
    final merchantKey = expense['merchantKey'] as String?;
    final title = expense['title'] as String?;

    if (merchantKey == null ||
        merchantKey == 'unknown' ||
        title == null) return;

    await _memory.recordAcceptance(
      merchantKey: merchantKey,
      title: title,
    );
  }
}
