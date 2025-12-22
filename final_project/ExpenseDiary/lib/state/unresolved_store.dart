import 'package:expense_tracker_app/services/suppression_storage.dart';
import 'package:flutter/foundation.dart';

import '../models/unresolved_transaction.dart';
import '../services/suppression_service.dart';
import '../services/suppression_key_builder.dart';

class UnresolvedStore extends ChangeNotifier {
  final List<UnresolvedTransaction> _items = [];

  final SuppressionService _suppressionService =
      SuppressionService(SuppressionStorage());

  /// Pending items only (what inbox shows)
  List<UnresolvedTransaction> get pendingItems =>
      _items.where((t) => t.status == UnresolvedStatus.pending).toList();

  // ─────────────────────────────────────────────
  // PHASE 3: SUPPRESSION-AWARE INGESTION
  // ─────────────────────────────────────────────

  /// Use this instead of addMock / addSMS later
  Future<void> addUnresolved(UnresolvedTransaction tx) async {
    final suppressionState = await _suppressionService.loadState();
    final key = SuppressionKeyBuilder.fromTransaction(tx);

    final rejectCount = suppressionState.rejectionCounts[key] ?? 0;

    // 🔕 Suppression rule:
    // If user rejected similar items 3+ times, ignore silently
    if (rejectCount >= 3) {
      return;
    }

    _items.add(tx);
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // PHASE 1 COMPATIBILITY (mock only)
  // ─────────────────────────────────────────────

  /// Temporary helper for mock data
  /// (internally uses suppression-aware path)
  Future<void> addMock(UnresolvedTransaction tx) async {
    await addUnresolved(tx);
  }

  // ─────────────────────────────────────────────
  // USER ACTIONS
  // ─────────────────────────────────────────────

  void accept(String id) {
    final tx = _items.firstWhere((t) => t.id == id);
    tx.status = UnresolvedStatus.accepted;
    notifyListeners();
  }

  void reject(String id) {
    final tx = _items.firstWhere((t) => t.id == id);
    tx.status = UnresolvedStatus.rejected;
    notifyListeners();
  }

  /// Optional cleanup helper
  void removeResolved() {
    _items.removeWhere(
      (t) => t.status != UnresolvedStatus.pending,
    );
    notifyListeners();
  }
}
