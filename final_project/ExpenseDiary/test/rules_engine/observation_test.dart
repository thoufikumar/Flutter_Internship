import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_app/rules_engine/observation.dart';
import 'package:expense_tracker_app/rules_engine/normalization.dart';
import 'package:expense_tracker_app/rules_engine/models.dart';
import 'test_utils.dart';

void main() {
  test('Front-loaded spending detected', () {
    final observer = Observer();

    final data = NormalizedData(
      trendExpenses: [
        food(100, 1),
        food(120, 2),
        food(150, 3),
        food(80, 25),
      ],
      categoryBaseline: {},
    );

    final signals = observer.observe(data, []);

    expect(signals.rhythm, Rhythm.frontLoaded);
  });

  test('Accelerating velocity detected', () {
    final observer = Observer();

    final data = NormalizedData(
      trendExpenses: [
        food(50, 1),
        food(60, 2),
        food(200, 20),
        food(220, 22),
      ],
      categoryBaseline: {},
    );

    final signals = observer.observe(data, []);

    expect(signals.velocity, Velocity.accelerating);
  });
}
