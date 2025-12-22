// observation.dart

import 'models.dart';
import 'normalization.dart';

class BehaviorSignals {
  final Velocity velocity;
  final Frequency frequency;
  final Rhythm rhythm;
  final Map<String, double> categoryUsage;
  final double manualEntryRatio;

  BehaviorSignals({
    required this.velocity,
    required this.frequency,
    required this.rhythm,
    required this.categoryUsage,
    required this.manualEntryRatio,
  });
}

class Observer {
  BehaviorSignals observe(
    NormalizedData data,
    List<Budget> budgets,
  ) {
    final frequency = _computeFrequency(data.trendExpenses);
    final rhythm = _detectRhythm(data.trendExpenses);
    final velocity = _computeVelocity(data.trendExpenses);
    final categoryUsage = _computeCategoryUsage(
      data.trendExpenses,
      budgets,
    );
    final manualRatio = _computeManualRatio(data.trendExpenses);

    return BehaviorSignals(
      velocity: velocity,
      frequency: frequency,
      rhythm: rhythm,
      categoryUsage: categoryUsage,
      manualEntryRatio: manualRatio,
    );
  }

  // --------------------------------------------------
  // OR-01: Spend Frequency
  // --------------------------------------------------
  Frequency _computeFrequency(List<Expense> expenses) {
    if (expenses.isEmpty) return Frequency.normal;

    final Set<DateTime> uniqueDays = expenses
        .map((e) => DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day))
        .toSet();

    final double days = uniqueDays.length.toDouble();

    if (days <= 2) return Frequency.low;
    if (days >= 6) return Frequency.high;

    return Frequency.normal;
  }

  // --------------------------------------------------
  // OR-02: Spend Rhythm (cycle shape)
  // --------------------------------------------------
  Rhythm _detectRhythm(List<Expense> expenses) {
    if (expenses.isEmpty) return Rhythm.even;

    int early = 0;
    int mid = 0;
    int late = 0;

    for (final e in expenses) {
      final day = e.timestamp.day;

      if (day <= 10) {
        early++;
      } else if (day <= 20) {
        mid++;
      } else {
        late++;
      }
    }

    final total = expenses.length.toDouble();

    if (early / total >= 0.5) return Rhythm.frontLoaded;
    if (mid / total >= 0.5) return Rhythm.midSpike;
    if (late / total >= 0.5) return Rhythm.endHeavy;

    return Rhythm.even;
  }

  // --------------------------------------------------
  // OR-03: Spend Velocity (rate of change)
  // --------------------------------------------------
  Velocity _computeVelocity(List<Expense> expenses) {
    if (expenses.length < 4) return Velocity.stable;

    final sorted = [...expenses]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final mid = sorted.length ~/ 2;

    final firstHalfTotal = sorted
        .sublist(0, mid)
        .fold<double>(0, (sum, e) => sum + e.amount);

    final secondHalfTotal = sorted
        .sublist(mid)
        .fold<double>(0, (sum, e) => sum + e.amount);

    if (firstHalfTotal == 0) return Velocity.stable;

    final changeRatio =
        (secondHalfTotal - firstHalfTotal) / firstHalfTotal;

    if (changeRatio >= 0.10) return Velocity.accelerating;
    if (changeRatio <= -0.10) return Velocity.decelerating;

    return Velocity.stable;
  }

  // --------------------------------------------------
  // Category usage (needed for awareness later)
  // --------------------------------------------------
  Map<String, double> _computeCategoryUsage(
    List<Expense> expenses,
    List<Budget> budgets,
  ) {
    final Map<String, double> usage = {};

    for (final budget in budgets) {
      final spent = expenses
          .where((e) => e.category == budget.category)
          .fold<double>(0, (sum, e) => sum + e.amount);

      usage[budget.category] =
          budget.allocatedAmount == 0
              ? 0
              : spent / budget.allocatedAmount;
    }

    return usage;
  }

  // --------------------------------------------------
  // OR-04: Manual vs Auto effort ratio
  // --------------------------------------------------
  double _computeManualRatio(List<Expense> expenses) {
    if (expenses.isEmpty) return 1.0;

    final manualCount =
        expenses.where((e) => e.source == ExpenseSource.manual).length;

    return manualCount / expenses.length;
  }
}
