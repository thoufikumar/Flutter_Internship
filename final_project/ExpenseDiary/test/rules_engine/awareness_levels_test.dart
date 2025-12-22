import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_app/rules_engine/rules_engine.dart';
import 'package:expense_tracker_app/rules_engine/models.dart';
import 'test_utils.dart';

void main() {
  test('60% category usage → context awareness', () {
    final engine = RulesEngine();

    final result = engine.evaluate(
      baseUser(
        expenses: List.generate(10, (i) => food(200, i + 1)),
        budgets: [Budget(category: 'Food', allocatedAmount: 3000)],
      ),
    );

    expect(result.level, AwarenessLevel.context);
    expect(result.reason, AwarenessReason.categoryUsage60);
  });

  test('85% usage → threshold awareness', () {
    final engine = RulesEngine();

    final result = engine.evaluate(
      baseUser(
        expenses: List.generate(10, (i) => food(300, i + 1)),
        budgets: [Budget(category: 'Food', allocatedAmount: 3000)],
      ),
    );

    expect(result.level, AwarenessLevel.threshold);
    expect(result.reason, AwarenessReason.categoryUsage85);
  });
}
