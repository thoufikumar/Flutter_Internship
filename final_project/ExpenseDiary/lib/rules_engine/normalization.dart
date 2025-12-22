// normalization.dart

import 'models.dart';

class NormalizedData {
  final List<Expense> trendExpenses;
  final Map<String, double> categoryBaseline;

  NormalizedData({
    required this.trendExpenses,
    required this.categoryBaseline,
  });
}

class Normalizer {
  NormalizedData normalize(UserData data) {
    final Map<String, List<double>> categoryAmounts = {};

    for (final expense in data.expenses) {
      categoryAmounts
          .putIfAbsent(expense.category, () => [])
          .add(expense.amount);
    }

    final Map<String, double> categoryBaseline = {};

    categoryAmounts.forEach((category, amounts) {
      if (amounts.length <= 1) {
        categoryBaseline[category] = amounts.first;
        return;
      }

      // Sort to remove largest outlier
      final sorted = [...amounts]..sort();
      final trimmed = sorted.sublist(0, sorted.length - 1);

      categoryBaseline[category] =
          trimmed.reduce((a, b) => a + b) / trimmed.length;
    });

    final trendExpenses = data.expenses.where((expense) {
      if (expense.isOneTime) return false;

      final baseline = categoryBaseline[expense.category];
      if (baseline == null) return true;

      return expense.amount <= baseline * 2.5;
    }).toList();

    return NormalizedData(
      trendExpenses: trendExpenses,
      categoryBaseline: categoryBaseline,
    );
  }
}
