// models.dart

import 'suppression.dart';
import 'observation.dart';

enum AwarenessLevel {
  none,
  reflection,
  context,
  threshold,
}

enum AwarenessReason {
  insufficientData,
  normalPattern,
  mildDeviation,
  frequencyChange,
  acceleratingSpend,
  categoryUsage60,
  categoryUsage85,
  dismissedPreviously,
  userSilent,
}

enum Velocity { stable, accelerating, decelerating }
enum Frequency { low, normal, high }
enum Rhythm { frontLoaded, midSpike, even, endHeavy }
enum ExpenseSource { manual, auto }

class Expense {
  final double amount;
  final String category;
  final DateTime timestamp;
  final bool isOneTime;
  final ExpenseSource source;

  Expense({
    required this.amount,
    required this.category,
    required this.timestamp,
    this.isOneTime = false,
    this.source = ExpenseSource.manual,
  });
}

class Budget {
  final String category;
  final double allocatedAmount;

  Budget({
    required this.category,
    required this.allocatedAmount,
  });
}

class Income {
  final double primaryIncome;
  Income({required this.primaryIncome});
}

class UserData {
  final int daysTracked;
  final List<Expense> expenses;
  final List<Budget> budgets;
  final Income? income;
  final SuppressionState suppression;
  final int? lastOpenedDaysAgo;

  UserData({
    required this.daysTracked,
    required this.expenses,
    required this.suppression,
    this.budgets = const [],
    this.income,
    this.lastOpenedDaysAgo,
  });

  int get totalExpenses => expenses.length;
}

class AwarenessResult {
  final AwarenessLevel level;
  final AwarenessReason reason;
  final String? category;

  const AwarenessResult({
    required this.level,
    required this.reason,
    this.category,
  });
}
