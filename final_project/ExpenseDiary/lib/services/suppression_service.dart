import 'package:expense_tracker_app/services/suppression_storage.dart';
import '../services/suppression_key_builder.dart';
import '../models/unresolved_transaction.dart';
import '../rules_engine/suppression.dart';

class SuppressionService {
  final SuppressionStorage _storage;

  SuppressionService(this._storage);

  Future<void> recordRejection(UnresolvedTransaction tx) async {
    final state = await _storage.load();
    final key = SuppressionKeyBuilder.fromTransaction(tx);

    state.rejectionCounts[key] =
        (state.rejectionCounts[key] ?? 0) + 1;

    await _storage.save(state);
  }

  Future<SuppressionState> loadState() {
    return _storage.load();
  }
}
