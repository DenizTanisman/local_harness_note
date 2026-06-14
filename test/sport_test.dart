import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/repositories/sport_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR3-P5 acceptance: name/set+duration validation, exercise-title and
/// food-type autocomplete persistence, superset grouping round-trip.
void main() {
  late AppDatabase db;
  late SportRepository sport;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    sport = SportRepository(db);
  });
  tearDown(() => db.close());

  group('ExerciseDraft validation', () {
    test('name required', () {
      expect(ExerciseDraft(name: '', sets: '3x10').isValid, isFalse);
      expect(ExerciseDraft(name: 'Squat', sets: '3x10').isValid, isTrue);
    });
    test('at least one of sets/duration', () {
      expect(ExerciseDraft(name: 'Squat').isValid, isFalse);
      expect(ExerciseDraft(name: 'Plank', duration: '60s').isValid, isTrue);
    });
  });

  group('saveProgram', () {
    test('rejects empty name and all-invalid blocks', () async {
      await expectLater(
        sport.saveProgram(
          name: '',
          blocks: [ExerciseDraft(name: 'x', sets: '1')],
        ),
        throwsArgumentError,
      );
      await expectLater(
        sport.saveProgram(
          name: 'Leg day',
          blocks: [ExerciseDraft(name: 'Squat')],
        ),
        throwsArgumentError,
      );
    });

    test('saves valid blocks and drops invalid ones', () async {
      final id = await sport.saveProgram(
        name: 'Leg day',
        blocks: [
          ExerciseDraft(name: 'Squat', sets: '15x3'),
          ExerciseDraft(name: '', sets: ''), // dropped
          ExerciseDraft(name: 'Plank', duration: '60s'),
        ],
      );
      final ex = await sport.exercisesFor(id);
      expect(ex.map((e) => e.name), ['Squat', 'Plank']);
      expect(ex[0].sets, '15x3');
      expect(ex[0].duration, isNull);
      expect(ex[1].duration, '60s');
    });

    test('every saved exercise name is remembered for autocomplete', () async {
      await sport.saveProgram(
        name: 'A',
        blocks: [
          ExerciseDraft(name: 'Bench Press', sets: '5x5'),
          ExerciseDraft(name: 'Squat', sets: '5x5'),
        ],
      );
      final titles = await sport.exerciseTitles();
      expect(titles, containsAll(['Bench Press', 'Squat']));

      // Survives into a fresh repository on the same db (next launch).
      final titles2 = await SportRepository(db).exerciseTitles();
      expect(titles2, contains('Squat'));
    });

    test('superset: two blocks share a group and round-trip', () async {
      final id = await sport.saveProgram(
        name: 'Push',
        blocks: [
          ExerciseDraft(
            name: 'Squat',
            sets: '15x3',
            supersetGroup: 1,
            supersetRounds: 3,
          ),
          ExerciseDraft(
            name: 'Lunge',
            sets: '12x3',
            supersetGroup: 1,
            supersetRounds: 3,
          ),
          ExerciseDraft(name: 'Plank', duration: '60s'),
        ],
      );
      final ex = await sport.exercisesFor(id);
      final superset = ex.where((e) => e.supersetGroup == 1).toList();
      expect(superset, hasLength(2));
      expect(superset.every((e) => e.supersetRounds == 3), isTrue);
      expect(ex.firstWhere((e) => e.name == 'Plank').supersetGroup, isNull);
    });
  });

  group('food types', () {
    test('builtins are seeded', () async {
      final types = await (db.select(db.savedFoodTypes)).get();
      expect(
        types.map((t) => t.name),
        containsAll(['Food', 'FastFood', 'Drink', 'Veg&Fruit']),
      );
      expect(types.where((t) => t.name == 'Food').single.isBuiltin, isTrue);
    });

    test('a new food type persists and is deduped', () async {
      await sport.addFoodType('Dessert');
      await sport.addFoodType('Dessert'); // INSERT OR IGNORE
      final types = await (db.select(
        db.savedFoodTypes,
      )..where((t) => t.name.equals('Dessert'))).get();
      expect(types, hasLength(1));
    });
  });

  group('calorie entries', () {
    test('adding an entry remembers a new type for next time', () async {
      await sport.addCalorieEntry(
        date: '2026-06-13',
        meal: 'lunch',
        kcal: 600,
        type: 'Homemade',
      );
      final entries = await (db.select(db.calorieEntries)).get();
      expect(entries.single.kcal, 600);
      expect(entries.single.type, 'Homemade');
      final types = await (db.select(
        db.savedFoodTypes,
      )..where((t) => t.name.equals('Homemade'))).get();
      expect(types, hasLength(1));
    });

    test('×N entry stores quantity + total and remembers category/per-unit',
        () async {
      await sport.addCalorieEntry(
        date: '2026-06-13',
        meal: 'breakfast',
        type: 'Apple',
        category: 'Fruit',
        kcalPerUnit: 20,
        quantity: 3,
        kcal: 60, // total = 20 × 3
      );

      final entry = (await db.select(db.calorieEntries).get()).single;
      expect(entry.quantity, 3);
      expect(entry.kcal, 60);
      expect(entry.type, 'Apple');

      final apple = await (db.select(
        db.savedFoodTypes,
      )..where((t) => t.name.equals('Apple'))).getSingle();
      expect(apple.category, 'Fruit');
      expect(apple.kcalPerUnit, 20);

      // The day intake reflects the total.
      final day = await sport.calorieDayFor('2026-06-13');
      expect(day!.intake, 60);
    });

    test('re-picking a saved food keeps its category, updates per-unit',
        () async {
      await sport.upsertFood(name: 'Banana', category: 'Fruit', kcalPerUnit: 90);
      // A later entry without a category must not wipe the remembered one.
      await sport.addCalorieEntry(
        date: '2026-06-13',
        type: 'Banana',
        kcalPerUnit: 95,
        kcal: 95,
      );
      final banana = await (db.select(
        db.savedFoodTypes,
      )..where((t) => t.name.equals('Banana'))).getSingle();
      expect(banana.category, 'Fruit', reason: 'category preserved');
      expect(banana.kcalPerUnit, 95, reason: 'per-unit updated');
    });
  });
}
