import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_app/rules_engine/normalization.dart';
import 'test_utils.dart';

void main() {
  test('One-time expense is excluded from trends', () {
    final normalizer = Normalizer();

    final normalized = normalizer.normalize(
      baseUser(
        expenses: [
          food(12000, 1, oneTime: true),
          food(200, 2),
        ],
      ),
    );

    expect(normalized.trendExpenses.length, 1);
  });

  test('Large expense auto-isolated (>2.5x baseline)', () {
    final normalizer = Normalizer();

    final normalized = normalizer.normalize(
      baseUser(
        expenses: [
          food(200, 1),
          food(220, 2),
          food(900, 3), // spike
        ],
      ),
    );

    expect(normalized.trendExpenses.length, 2);
  });
}
