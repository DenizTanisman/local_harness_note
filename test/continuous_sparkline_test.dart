import 'package:local_harness_not/features/shared/continuous_sparkline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR1-C acceptance: full-month line with zeros for empty days, flat line
/// for an empty month, clamped nearest-day taps, per-day segment colors.
void main() {
  group('filledMonthValues', () {
    test('30-day month with 3 data days → 27 zeros + 3 peaks', () {
      final values = filledMonthValues(30, {5: 20.0, 12: 40.0, 28: 10.0});
      expect(values, hasLength(30));
      expect(values.where((v) => v == 0), hasLength(27));
      expect(values[4], 20);
      expect(values[11], 40);
      expect(values[27], 10);
    });

    test('completely empty month → all zeros (flat baseline, no crash)', () {
      final values = filledMonthValues(31, {});
      expect(values, hasLength(31));
      expect(values.every((v) => v == 0), isTrue);
    });

    test('0 value and missing day are identical (deliberate)', () {
      final withZero = filledMonthValues(30, {5: 0.0});
      final without = filledMonthValues(30, {});
      expect(withZero, without);
    });
  });

  group('segment colors', () {
    test('a highlighted day owns the segment rising to it', () {
      // Index 0 unused; day 10 highlighted, every other day plain.
      final colors = [
        for (var d = 0; d <= 30; d++) d == 10 ? Colors.red : Colors.green,
      ];
      // The segment arriving at day 10 (left index 8) is red.
      expect(segmentColor(8, colors, Colors.white), Colors.red);
      expect(segmentColor(9, colors, Colors.white), Colors.green);
      expect(segmentColor(10, colors, Colors.white), colors[12]);
    });

    test('without dayColors the fallback line color is used', () {
      expect(segmentColor(3, null, sparklineGreen), sparklineGreen);
    });
  });

  group('widget', () {
    testWidgets('empty month renders a flat line without crashing', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContinuousSparkline(
              daysInMonth: 30,
              values: {},
              selectedDay: 11,
            ),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('sparkline')), findsOneWidget);
    });

    testWidgets('taps round to the nearest day and clamp at month edges', (
      tester,
    ) async {
      final taps = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContinuousSparkline(
              daysInMonth: 30,
              values: const {10: 5.0},
              selectedDay: 1,
              onDayTap: taps.add,
            ),
          ),
        ),
      );
      final rect = tester.getRect(find.byKey(const ValueKey('sparkline')));
      final step = rect.width / 29;

      await tester.tapAt(Offset(rect.left + step * 9, rect.center.dy));
      await tester.tapAt(Offset(rect.left + 1, rect.center.dy));
      await tester.tapAt(Offset(rect.right - 1, rect.center.dy));
      expect(taps, [10, 1, 30]); // nearest, clamped left, clamped right
    });
  });
}
