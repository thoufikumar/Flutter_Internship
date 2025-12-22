import 'package:flutter/foundation.dart';
import '../rules_engine/awareness_gate.dart';
import '../rules_engine/rules_engine.dart';
import '../rules_engine/models.dart';
import '../rules_engine/suppression.dart';
import '../services/suppression_storage.dart';
import '../rules_engine/normalization.dart';
import '../rules_engine/observation.dart';

class AwarenessProvider extends ChangeNotifier {
  final RulesEngine _rulesEngine;
  final SuppressionStorage _storage;
  BehaviorSignals? _signals;
BehaviorSignals? get signals => _signals;


  AwarenessResult? _current;
  SuppressionState _suppression;

  AwarenessProvider({
    RulesEngine? rulesEngine,
    SuppressionStorage? storage,
    SuppressionState? initialSuppression,
  })  : _rulesEngine = rulesEngine ?? RulesEngine(),
        _storage = storage ?? SuppressionStorage(),
        _suppression = initialSuppression ?? SuppressionState();

  AwarenessResult? get currentAwareness => _current;

  bool get hasAwareness =>
      _current != null && _current!.level != AwarenessLevel.none;

  SuppressionState get suppression => _suppression;

  /// Load persisted suppression (call on app start / login)
  Future<void> loadSuppression() async {
    _suppression = await _storage.load();
    notifyListeners();
  }

  // ───────────────────────────────
  // Phase 5 – Awareness evaluation + gating
  // ───────────────────────────────
  void refresh(UserData data) {
    final enrichedData = UserData(
      daysTracked: data.daysTracked,
      expenses: data.expenses,
      budgets: data.budgets,
      income: data.income,
      lastOpenedDaysAgo: data.lastOpenedDaysAgo,
      suppression: _suppression,
    );

    final result = _rulesEngine.evaluate(enrichedData);
final normalizer = Normalizer();
final observer = Observer();

final normalized = normalizer.normalize(enrichedData);

_signals = observer.observe(
  normalized,
  enrichedData.budgets,
);

    final lastExpense =
        data.expenses.isNotEmpty ? data.expenses.last : null;

    final bool isOneTime = lastExpense?.isOneTime ?? false;
    final String? category = lastExpense?.category;

    final int similarCountLast14Days =
        _calculateSimilarCount(data, category);

    final bool recentlyDismissed =
        result.category != null &&
        _suppression.dismissedSignals.contains(result.category);

    final bool allowed = AwarenessGate.shouldAllow(
      result: result,
      isOneTime: isOneTime,
      category: category,
      similarCountLast14Days: similarCountLast14Days,
      recentlyDismissed: recentlyDismissed,
    );

    _current = allowed ? result : null;
    notifyListeners();
  }

  // ───────────────────────────────
  // Suppression actions (used by UI)
  // ───────────────────────────────

  /// User dismissed awareness (soft suppression)
  Future<void> dismissCurrent() async {
    if (_current?.category != null) {
      _suppression.dismiss(_current!.category!);
      await _storage.save(_suppression);
    }

    _current = null;
    notifyListeners();
  }

  /// User strongly rejected awareness (hard suppression)
  Future<void> rejectCurrent() async {
    if (_current?.category != null) {
      _suppression.reject(_current!.category!);
      await _storage.save(_suppression);
    }

    _current = null;
    notifyListeners();
  }

  // ───────────────────────────────
  // Helpers
  // ───────────────────────────────

  int _calculateSimilarCount(
    UserData data,
    String? category,
  ) {
    if (category == null) return 0;

    final cutoff =
        DateTime.now().subtract(const Duration(days: 14));

    return data.expenses.where((e) {
      return e.category == category &&
          e.timestamp.isAfter(cutoff) &&
          !e.isOneTime;
    }).length;
  }
}
