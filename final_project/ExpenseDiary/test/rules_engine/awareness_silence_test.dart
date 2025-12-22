import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_app/rules_engine/rules_engine.dart';
import 'package:expense_tracker_app/rules_engine/models.dart';
import 'test_utils.dart';

void main() {
  test('New user stays silent (insufficient data)', () {
    final engine = RulesEngine();

    final result = engine.evaluate(
      baseUser(
        daysTracked: 3,
        expenses: [food(100, 1), food(120, 2)],
      ),
    );

    expect(result.level, AwarenessLevel.none);
    expect(result.reason, AwarenessReason.insufficientData);
  });

  test('Inactive user stays silent', () {
    final engine = RulesEngine();

    final result = engine.evaluate(
      baseUser(
        expenses: List.generate(20, (i) => food(100, i + 1)),
        lastOpenedDaysAgo: 10,
      ),
    );

    expect(result.level, AwarenessLevel.none);
    expect(result.reason, AwarenessReason.userSilent);
  });
}
