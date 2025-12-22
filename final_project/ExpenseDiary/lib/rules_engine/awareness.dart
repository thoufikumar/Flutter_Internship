// awareness.dart

import 'models.dart';
import 'observation.dart';

class AwarenessEvaluator {
  AwarenessResult evaluate(
    UserData data,
    BehaviorSignals signals,
  ) {
    // 1. SUPPRESSION
    for (final entry in signals.categoryUsage.entries) {
      if (data.suppression.isMuted(entry.key) ||
          data.suppression.isDismissed(entry.key)) {
        return const AwarenessResult(
          level: AwarenessLevel.none,
          reason: AwarenessReason.dismissedPreviously,
        );
      }
    }

    // 2. SILENCE
    if (data.daysTracked < 7 ||
        (data.totalExpenses < 15 && data.budgets.isEmpty)) {
      return const AwarenessResult(
        level: AwarenessLevel.none,
        reason: AwarenessReason.insufficientData,
      );
    }

    if (data.lastOpenedDaysAgo != null &&
        data.lastOpenedDaysAgo! > 7) {
      return const AwarenessResult(
        level: AwarenessLevel.none,
        reason: AwarenessReason.userSilent,
      );
    }

    // 3. THRESHOLD
    for (final entry in signals.categoryUsage.entries) {
      if (entry.value >= 0.85) {
        return AwarenessResult(
          level: AwarenessLevel.threshold,
          category: entry.key,
          reason: AwarenessReason.categoryUsage85,
        );
      }
    }

    // 4. CONTEXT
    for (final entry in signals.categoryUsage.entries) {
      if (entry.value >= 0.60) {
        return AwarenessResult(
          level: AwarenessLevel.context,
          category: entry.key,
          reason: AwarenessReason.categoryUsage60,
        );
      }
    }

    if (signals.velocity == Velocity.accelerating) {
      return const AwarenessResult(
        level: AwarenessLevel.context,
        reason: AwarenessReason.acceleratingSpend,
      );
    }

    // 5. REFLECTION
    if (signals.frequency != Frequency.normal ||
        signals.rhythm != Rhythm.even) {
      return const AwarenessResult(
        level: AwarenessLevel.reflection,
        reason: AwarenessReason.mildDeviation,
      );
    }

    return const AwarenessResult(
      level: AwarenessLevel.none,
      reason: AwarenessReason.normalPattern,
    );
  }
}
