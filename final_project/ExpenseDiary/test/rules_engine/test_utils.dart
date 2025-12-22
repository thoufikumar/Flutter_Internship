import 'package:expense_tracker_app/rules_engine/models.dart';
import 'package:expense_tracker_app/rules_engine/suppression.dart';

UserData baseUser({
  required List<Expense> expenses,
  int daysTracked = 30,
  List<Budget> budgets = const [],
  int? lastOpenedDaysAgo,
  SuppressionState? suppression,
}) {
  return UserData(
    daysTracked: daysTracked,
    expenses: expenses,
    budgets: budgets,
    suppression: suppression ?? SuppressionState(),
    lastOpenedDaysAgo: lastOpenedDaysAgo,
  );
}

Expense food(double amount, int day,
    {bool oneTime = false, ExpenseSource source = ExpenseSource.manual}) {
  return Expense(
    amount: amount,
    category: 'Food',
    timestamp: DateTime(2025, 1, day),
    isOneTime: oneTime,
    source: source,
  );
}
