import 'package:drift/drift.dart';

import '../../features/sport/calorie_color.dart';
import '../db/app_database.dart';

/// One exercise block being authored in the New Program flow.
class ExerciseDraft {
  ExerciseDraft({
    required this.name,
    this.sets,
    this.duration,
    this.restAfter = false,
    this.supersetGroup,
    this.supersetRounds,
  });

  String name;
  String? sets;
  String? duration;
  bool restAfter;
  int? supersetGroup;
  int? supersetRounds;

  /// CR-3 §6.2: name required, and at least one of sets/duration filled.
  bool get isValid =>
      name.trim().isNotEmpty &&
      ((sets?.trim().isNotEmpty ?? false) ||
          (duration?.trim().isNotEmpty ?? false));
}

class SportRepository {
  SportRepository(this.db);

  final AppDatabase db;

  // ---------- programs ----------

  Stream<List<Program>> watchPrograms() {
    final query = db.select(db.programs)
      ..orderBy([
        (p) => OrderingTerm.asc(p.sortOrder),
        (p) => OrderingTerm.asc(p.id),
      ]);
    return query.watch();
  }

  Stream<List<ProgramExercise>> watchExercises(int programId) {
    final query = db.select(db.programExercises)
      ..where((e) => e.programId.equals(programId))
      ..orderBy([(e) => OrderingTerm.asc(e.sortOrder)]);
    return query.watch();
  }

  Future<List<ProgramExercise>> exercisesFor(int programId) {
    final query = db.select(db.programExercises)
      ..where((e) => e.programId.equals(programId))
      ..orderBy([(e) => OrderingTerm.asc(e.sortOrder)]);
    return query.get();
  }

  /// Saves a program with its exercise blocks. Every block name is also
  /// remembered for autocomplete (CR-3 §12). Throws if validation fails.
  Future<int> saveProgram({
    required String name,
    required List<ExerciseDraft> blocks,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Program name is required');
    }
    final valid = blocks.where((b) => b.isValid).toList();
    if (valid.isEmpty) {
      throw ArgumentError('A program needs at least one valid exercise');
    }
    return db.transaction(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final maxOrder = db.programs.sortOrder.max();
      final row = await (db.selectOnly(
        db.programs,
      )..addColumns([maxOrder])).getSingle();
      final programId = await db
          .into(db.programs)
          .insert(
            ProgramsCompanion.insert(
              name: name.trim(),
              createdAt: now,
              sortOrder: Value((row.read(maxOrder) ?? -1) + 1),
            ),
          );
      for (var i = 0; i < valid.length; i++) {
        final b = valid[i];
        await db
            .into(db.programExercises)
            .insert(
              ProgramExercisesCompanion.insert(
                programId: programId,
                name: b.name.trim(),
                sets: Value(_clean(b.sets)),
                duration: Value(_clean(b.duration)),
                restAfter: Value(b.restAfter),
                supersetGroup: Value(b.supersetGroup),
                supersetRounds: Value(b.supersetRounds),
                sortOrder: Value(i),
              ),
            );
        await rememberExerciseTitle(b.name);
      }
      return programId;
    });
  }

  Future<void> deleteProgram(int id) =>
      (db.delete(db.programs)..where((p) => p.id.equals(id))).go();

  // ---------- autocomplete ----------

  Future<void> rememberExerciseTitle(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await db
        .into(db.savedExerciseTitles)
        .insert(
          SavedExerciseTitlesCompanion.insert(name: trimmed),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Stream<List<String>> watchExerciseTitles() =>
      (db.select(db.savedExerciseTitles)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch()
          .map((rows) => [for (final r in rows) r.name]);

  Future<List<String>> exerciseTitles() async {
    final rows = await (db.select(
      db.savedExerciseTitles,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
    return [for (final r in rows) r.name];
  }

  Stream<List<String>> watchFoodTypes() =>
      (db.select(db.savedFoodTypes)..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch()
          .map((rows) => [for (final r in rows) r.name]);

  Future<void> addFoodType(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await db
        .into(db.savedFoodTypes)
        .insert(
          SavedFoodTypesCompanion.insert(name: trimmed),
          mode: InsertMode.insertOrIgnore,
        );
  }

  // ---------- calorie entries ----------

  /// Adds a calorie entry; the food [type] is remembered for autocomplete
  /// (CR-3 §12). Updates the derived calorie_day: the target snapshot is
  /// FROZEN on the day's first entry from [currentTarget] (the live
  /// TDEE_static), and the stored color is recomputed against that frozen
  /// snapshot — so changing the target later never recolors past days
  /// (§11).
  Future<int> addCalorieEntry({
    required String date,
    String? meal,
    required double kcal,
    required String type,
    double? currentTarget,
  }) {
    return db.transaction(() async {
      await addFoodType(type);
      final id = await db
          .into(db.calorieEntries)
          .insert(
            CalorieEntriesCompanion.insert(
              date: date,
              meal: Value(meal),
              kcal: kcal,
              type: type.trim(),
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );

      final existing = await (db.select(
        db.calorieDay,
      )..where((d) => d.date.equals(date))).getSingleOrNull();
      // Freeze the snapshot on the first entry of the day.
      final snapshot = existing?.targetSnapshot ?? currentTarget;
      final intake = (existing?.intake ?? 0) + kcal;
      await db
          .into(db.calorieDay)
          .insertOnConflictUpdate(
            CalorieDayCompanion(
              date: Value(date),
              intake: Value(intake),
              targetSnapshot: Value(snapshot),
              color: Value(calorieColor(intake, snapshot)),
            ),
          );
      return id;
    });
  }

  Stream<List<CalorieEntry>> watchCalorieEntries(String date) {
    final query = db.select(db.calorieEntries)
      ..where((e) => e.date.equals(date))
      ..orderBy([(e) => OrderingTerm.asc(e.createdAt)]);
    return query.watch();
  }

  Future<CalorieDayData?> calorieDayFor(String date) => (db.select(
    db.calorieDay,
  )..where((d) => d.date.equals(date))).getSingleOrNull();

  /// Day-of-month → calorie_day for [month] (CR-3 §11 sparkline source).
  Stream<Map<int, CalorieDayData>> watchCalorieMonth(String month) {
    final query = db.select(db.calorieDay)
      ..where((d) => d.date.like('$month-%'));
    return query.watch().map(
      (rows) => {for (final r in rows) int.parse(r.date.substring(8)): r},
    );
  }

  // ---------- program log (Programs sparkline) ----------

  /// Records that [programId] was done on [date] with [volume] (CR-3 §11).
  Future<void> logProgram({
    required String date,
    required int programId,
    double volume = 0,
  }) async {
    await db
        .into(db.programLog)
        .insert(
          ProgramLogCompanion.insert(
            date: date,
            programId: programId,
            volume: Value(volume),
          ),
        );
  }

  /// Day-of-month → (volume, last programId) for [month] (sparkline + tap).
  Stream<Map<int, ({double volume, int programId})>> watchProgramMonth(
    String month,
  ) {
    final query = db.select(db.programLog)
      ..where((l) => l.date.like('$month-%'))
      ..orderBy([(l) => OrderingTerm.asc(l.date)]);
    return query.watch().map((rows) {
      final out = <int, ({double volume, int programId})>{};
      for (final r in rows) {
        final day = int.parse(r.date.substring(8));
        final prev = out[day];
        out[day] = (
          volume: (prev?.volume ?? 0) + r.volume,
          programId: r.programId,
        );
      }
      return out;
    });
  }

  String? _clean(String? raw) {
    final t = raw?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}
