// suppression.dart

class SuppressionState {
  final Set<String> dismissedSignals = {};
  final Map<String, int> rejectionCounts = {};

  bool isDismissed(String key) {
    return dismissedSignals.contains(key);
  }

  void dismiss(String key) {
    dismissedSignals.add(key);
  }

  void reject(String key) {
    rejectionCounts[key] = (rejectionCounts[key] ?? 0) + 1;
  }

  bool isMuted(String key) {
    return (rejectionCounts[key] ?? 0) >= 2;
  }
}
