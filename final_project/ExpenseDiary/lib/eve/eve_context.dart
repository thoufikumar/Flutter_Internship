import '../rules_engine/models.dart';

class EveContext {
  final AwarenessLevel level;
  final String? category;

  /// 🔒 Pre-interpreted, human-readable observations
  /// EVE must ONLY explain these — not derive meaning
  final List<String> observations;

  EveContext({
    required this.level,
    this.category,
    required this.observations,
  });
}
