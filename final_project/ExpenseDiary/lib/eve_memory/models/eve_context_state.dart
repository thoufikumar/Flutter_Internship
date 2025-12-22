import '../../rules_engine/models.dart';

class EveContextState {
  final AwarenessLevel level;
  final AwarenessReason reason;
  final String? category;
  final DateTime lastEvaluatedAt;

  EveContextState({
    required this.level,
    required this.reason,
    this.category,
    required this.lastEvaluatedAt,
  });

  bool get hasAnythingToExplain =>
      level != AwarenessLevel.none;
}
