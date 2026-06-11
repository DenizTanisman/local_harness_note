import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/repositories/money_repository.dart';
import 'package:daily_tracker/features/money/money_page.dart';
import 'package:daily_tracker/features/shared/continuous_sparkline.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR1-C acceptance: full-month line with zeros for empty days, flat line
/// for an empty month, clamped nearest-day taps, red segments for
/// over-budget Money days.
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

  group('segment colors (Money red/green)', () {
    test('over-budget day owns the segment rising to it', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final money = MoneyRepository(db);
      // Budget: (3000 − 0) / 30 = 100; day 10 spends 200 → red.
      await money.addTransaction(
          date: '2026-06-01',
          direction: 'income',
          amount: 3000,
          category: 'Scholarship');
      await money.addTransaction(
          date: '2026-06-10',
          direction: 'outcome',
          amount: 200,
          category: 'Food');
      await money.addTransaction(
          date: '2026-06-11',
          direction: 'outcome',
          amount: 50,
          category: 'Food');

      final general = await money.loadGeneral('2026-06');
      final colors = moneyDayColors(30, general);
      expect(colors[10], const Color(0xFFDA3633), reason: 'day 10 red');
      expect(colors[11], const Color(0xFF2EA043), reason: 'day 11 green');

      // The segment arriving at day 10 (left index 8) is red.
      expect(segmentColor(8, colors, Colors.white), colors[10]);
      expect(segmentColor(10, colors, Colors.white), colors[11]);
    });

    test('without dayColors the fallback line color is used', () {
      expect(segmentColor(3, null, sparklineGreen), sparklineGreen);
    });
  });

  group('widget', () {
    testWidgets('empty month renders a flat line without crashing',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ContinuousSparkline(
            daysInMonth: 30,
            values: {},
            selectedDay: 11,
          ),
        ),
      ));
      expect(find.byKey(const ValueKey('sparkline')), findsOneWidget);
    });

    testWidgets('taps round to the nearest day and clamp at month edges',
        (tester) async {
      final taps = <int>[];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ContinuousSparkline(
            daysInMonth: 30,
            values: const {10: 5.0},
            selectedDay: 1,
            onDayTap: taps.add,
          ),
        ),
      ));
      final rect =
          tester.getRect(find.byKey(const ValueKey('sparkline')));
      final step = rect.width / 29;

      await tester.tapAt(Offset(rect.left + step * 9, rect.center.dy));
      await tester.tapAt(Offset(rect.left + 1, rect.center.dy));
      await tester.tapAt(Offset(rect.right - 1, rect.center.dy));
      expect(taps, [10, 1, 30]); // nearest, clamped left, clamped right
    });
  });
}
