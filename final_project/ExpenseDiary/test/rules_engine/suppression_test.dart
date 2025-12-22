import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_app/rules_engine/rules_engine.dart';
import 'package:expense_tracker_app/rules_engine/suppression.dart';
import 'package:expense_tracker_app/rules_engine/models.dart';
import 'test_utils.dart';

void main() {
  test('Dismissed category stays silent', () {
    final suppression = SuppressionState();
    suppression.dismiss('Food');

    final engine = RulesEngine();

    final result = engine.evaluate(
      baseUser(
        expenses: List.generate(10, (i) => food(300, i + 1)),
        budgets: [Budget(category: 'Food', allocatedAmount: 3000)],
        suppression: suppression,
      ),
    );

    expect(result.level, AwarenessLevel.none);
    expect(result.reason, AwarenessReason.dismissedPreviously);
  });
}
