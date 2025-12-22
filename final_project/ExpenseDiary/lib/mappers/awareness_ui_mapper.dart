import '../rules_engine/models.dart';

class AwarenessUIModel {
  final String title;
  final String message;
  final bool showDismiss;

  const AwarenessUIModel({
    required this.title,
    required this.message,
    this.showDismiss = false,
  });
}

class AwarenessUIMapper {
  static AwarenessUIModel? fromAwareness(AwarenessResult result) {
    switch (result.reason) {
      case AwarenessReason.categoryUsage60:
        return AwarenessUIModel(
          title: 'Just a heads up',
          message:
              'You’ve used a good part of your ${result.category} budget.',
          showDismiss: true,
        );

      case AwarenessReason.categoryUsage85:
        return AwarenessUIModel(
          title: 'Pause & check',
          message:
              'Your ${result.category} spending is close to its limit.',
          showDismiss: true,
        );

      case AwarenessReason.acceleratingSpend:
        return const AwarenessUIModel(
          title: 'Noticing a pattern',
          message:
              'Spending has been increasing recently.',
          showDismiss: true,
        );

      case AwarenessReason.frequencyChange:
        return const AwarenessUIModel(
          title: 'Just observing',
          message:
              'Your spending frequency looks a little different lately.',
        );

      case AwarenessReason.mildDeviation:
        return const AwarenessUIModel(
          title: 'FYI',
          message:
              'Your spending pattern looks slightly different this time.',
        );

      default:
        return null; // silence is intentional
    }
  }
}
