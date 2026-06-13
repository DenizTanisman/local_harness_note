import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/repositories/sport_repository.dart';
import 'package:daily_tracker/features/sport/calorie_color.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR3-P6 §11 acceptance: the per-day target snapshot freezes on the first
/// entry and past days never recolor when the target later changes.
void main() {
  group('calorieColor rule (§11)', () {
    test('yellow under, red over, green within ±100', () {
      expect(calorieColor(2000, 2600), 'yellow'); // < 2500
      expect(calorieColor(2900, 2600), 'red'); // > 2700
      expect(calorieColor(2600, 2600), 'green');
      expect(calorieColor(2500, 2600), 'green'); // boundary inclusive
      expect(calorieColor(2700, 2600), 'green');
    });
    test('null target → null (neutral)', () {
      expect(calorieColor(2000, null), isNull);
    });
  });

  group('calorie_day snapshot', () {
    late AppDatabase db;
    late SportRepository sport;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      sport = SportRepository(db);
    });
    tearDown(() => db.close());

    test('snapshot frozen on first entry; intake accumulates', () async {
      await sport.addCalorieEntry(
        date: '2026-06-10',
        kcal: 2000,
        type: 'Food',
        currentTarget: 2600,
      );
      var day = await sport.calorieDayFor('2026-06-10');
      expect(day!.targetSnapshot, 2600);
      expect(day.intake, 2000);
      expect(day.color, 'yellow');

      // Second entry the same day, even if the live target changed.
      await sport.addCalorieEntry(
        date: '2026-06-10',
        kcal: 700,
        type: 'Drink',
        currentTarget: 9999,
      );
      day = await sport.calorieDayFor('2026-06-10');
      expect(day!.targetSnapshot, 2600, reason: 'snapshot stays frozen');
      expect(day.intake, 2700);
      expect(day.color, 'green'); // 2700 within [2500,2700]
    });

    test(
      'changing the target only affects NEW days; old days keep color',
      () async {
        // Day 1 with target 2600 → over.
        await sport.addCalorieEntry(
          date: '2026-06-10',
          kcal: 3000,
          type: 'Food',
          currentTarget: 2600,
        );
        // Day 2 with a raised target 3200 → same intake now under.
        await sport.addCalorieEntry(
          date: '2026-06-11',
          kcal: 3000,
          type: 'Food',
          currentTarget: 3200,
        );

        final d1 = await sport.calorieDayFor('2026-06-10');
        final d2 = await sport.calorieDayFor('2026-06-11');
        expect(d1!.targetSnapshot, 2600);
        expect(d1.color, 'red', reason: 'frozen at old target');
        expect(d2!.targetSnapshot, 3200);
        expect(d2.color, 'yellow', reason: 'new day uses new target');
      },
    );

    test('no target (no profile) → snapshot null, color null', () async {
      await sport.addCalorieEntry(date: '2026-06-10', kcal: 1500, type: 'Food');
      final day = await sport.calorieDayFor('2026-06-10');
      expect(day!.targetSnapshot, isNull);
      expect(day.color, isNull);
      expect(day.intake, 1500);
    });
  });

  group('program log', () {
    late AppDatabase db;
    late SportRepository sport;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      sport = SportRepository(db);
    });
    tearDown(() => db.close());

    test('month series aggregates volume and keeps the program id', () async {
      final id = await sport.saveProgram(
        name: 'Push',
        blocks: [ExerciseDraft(name: 'Bench', sets: '5x5')],
      );
      await sport.logProgram(date: '2026-06-10', programId: id, volume: 3);
      await sport.logProgram(date: '2026-06-10', programId: id, volume: 2);

      final series = await sport.watchProgramMonth('2026-06').first;
      expect(series[10]!.volume, 5);
      expect(series[10]!.programId, id);
    });
  });
}
