import 'models.dart';

class AwarenessGate {
  static bool shouldAllow({
    required AwarenessResult result,

    required bool isOneTime,
    String? category,

    required int similarCountLast14Days,
    required bool recentlyDismissed,
  }) {
    // Rule 0: no awareness anyway
    if (result.level == AwarenessLevel.none) {
      return false;
    }

    // Rule 1: One-time expenses never create awareness
    if (isOneTime) return false;

    // Rule 2: Category eligibility
    const eligibleCategories = {
      'Food',
      'Transport',
      'Shopping',
      'Entertainment',
      'Bills',
    };

    final awarenessCategory = category ?? result.category;

    if (awarenessCategory == null ||
        !eligibleCategories.contains(awarenessCategory)) {
      return false;
    }

    // Rule 3: Minimum repetition
    if (similarCountLast14Days < 3) {
      return false;
    }

    // Rule 4: Recently dismissed
    if (recentlyDismissed) {
      return false;
    }

    return true;
  }
}
