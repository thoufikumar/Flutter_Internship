import '../rules_engine/models.dart';
import 'eve_context.dart';

class EveObservationMapper {
  static EveContext map({
    required AwarenessLevel level,
    required AwarenessReason reason,
    String? category,
    Velocity? velocity,
    Frequency? frequency,
    Rhythm? rhythm,
  }) {
    final observations = <String>[];

    switch (reason) {
      case AwarenessReason.categoryUsage60:
        observations.add(
          'This category has been appearing more consistently over time.',
        );
        break;

      case AwarenessReason.categoryUsage85:
        observations.add(
          'This category is now taking a noticeably larger share of spending.',
        );
        break;

      case AwarenessReason.acceleratingSpend:
        observations.add(
          'Spending pace increased compared to earlier in the period.',
        );
        break;

      case AwarenessReason.frequencyChange:
        observations.add(
          'The frequency of expenses shifted compared to before.',
        );
        break;

      case AwarenessReason.insufficientData:
        observations.add(
          'There is not enough recent data to form a clear pattern yet.',
        );
        break;

      default:
        observations.add(
          'Spending patterns are consistent with previous behavior.',
        );
    }

    // Optional signal-based additions (still neutral)
    if (velocity == Velocity.accelerating) {
      observations.add(
        'Recent entries occurred closer together in time.',
      );
    }

    if (rhythm == Rhythm.frontLoaded) {
      observations.add(
        'Expenses appeared earlier in the cycle than usual.',
      );
    }

    return EveContext(
      level: level,
      category: category,
      observations: observations,
    );
  }
}
