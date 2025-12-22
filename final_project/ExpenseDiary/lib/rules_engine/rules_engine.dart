// rules_engine.dart

import 'models.dart';
import 'normalization.dart';
import 'observation.dart';
import 'awareness.dart';

import '../eve_memory/models/eve_context_state.dart';
import '../eve_memory/eve_context_store.dart';

class RulesEngine {
  final Normalizer _normalizer = Normalizer();
  final Observer _observer = Observer();
  final AwarenessEvaluator _evaluator = AwarenessEvaluator();

  AwarenessResult evaluate(UserData data) {
    final normalized = _normalizer.normalize(data);

    final signals = _observer.observe(
      normalized,
      data.budgets,
    );

    final result = _evaluator.evaluate(data, signals);

    // ✅ Persist BEHAVIORAL MEMORY (awareness only)
    final memoryState = EveContextState(
      level: result.level,
      category: result.category,
      reason: result.reason,
      lastEvaluatedAt: DateTime.now(),
    );

    EveContextStore.instance.save(memoryState);

    return result;
  }
}
