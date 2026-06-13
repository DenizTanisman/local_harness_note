import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// Daily fetched vitals (CR-3 §9). All nullable — null means "no data /
/// not connected", rendered as '—'.
class DailyVitals {
  const DailyVitals({
    this.restingHr,
    this.hrDay,
    this.sleepMin,
    this.sleepScore,
    this.steps,
    this.vo2max,
    this.activeKcal,
  });

  final double? restingHr;
  final double? hrDay;
  final double? sleepMin;
  final double? sleepScore;
  final double? steps;
  final double? vo2max;
  final double? activeKcal;

  bool get isEmpty =>
      restingHr == null &&
      hrDay == null &&
      sleepMin == null &&
      sleepScore == null &&
      steps == null &&
      vo2max == null &&
      activeKcal == null;
}

/// Computed body summary derived on write (CR-3 §10).
class BodyStats {
  const BodyStats({this.bmi, this.bmr, this.tdeeStatic});

  final double? bmi;
  final double? bmr;
  final double? tdeeStatic;
}

/// DB-backed health profile + body log + sensor reads. The sensor side is
/// a placeholder until a HealthSource is wired (P4): `vitalsFor` reads
/// `health_samples`, which stays empty, so the UI shows '—' + Connect.
class HealthRepository {
  HealthRepository(this.db);

  final AppDatabase db;

  // ---------- profile ----------

  Stream<HealthProfileData?> watchProfile() => (db.select(
    db.healthProfile,
  )..where((p) => p.id.equals(1))).watchSingleOrNull();

  Future<HealthProfileData?> loadProfile() => (db.select(
    db.healthProfile,
  )..where((p) => p.id.equals(1))).getSingleOrNull();

  Future<void> saveProfile({
    String? birthDate,
    String? sex,
    double? heightCm,
    String? activityLevel,
  }) async {
    await db
        .into(db.healthProfile)
        .insertOnConflictUpdate(
          HealthProfileCompanion(
            id: const Value(1),
            birthDate: Value(birthDate),
            sex: Value(sex),
            heightCm: Value(heightCm),
            activityLevel: Value(activityLevel),
            updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  // ---------- body ----------

  /// Most recent body measurement (CR-3 §5 — calculations use the latest).
  Stream<BodyLogData?> watchLatestBody() {
    final query = db.select(db.bodyLog)
      ..orderBy([(b) => OrderingTerm.desc(b.date)])
      ..limit(1);
    return query.watchSingleOrNull();
  }

  Future<BodyLogData?> loadLatestBody() {
    final query = db.select(db.bodyLog)
      ..orderBy([(b) => OrderingTerm.desc(b.date)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<void> saveBody({
    required String date,
    double? weightKg,
    double? bodyFatPct,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db
        .into(db.bodyLog)
        .insert(
          BodyLogCompanion.insert(
            date: date,
            weightKg: Value(weightKg),
            bodyFatPct: Value(bodyFatPct),
            createdAt: now,
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (_) => BodyLogCompanion(
              weightKg: Value(weightKg),
              bodyFatPct: Value(bodyFatPct),
              updatedAt: Value(now),
            ),
            target: [db.bodyLog.date],
          ),
        );
  }

  // ---------- sensors (placeholder until P4) ----------

  Future<DailyVitals> vitalsFor(String date) async {
    final rows = await (db.select(
      db.healthSamples,
    )..where((s) => s.date.equals(date))).get();
    if (rows.isEmpty) return const DailyVitals();
    double? v(String kind) =>
        rows.where((r) => r.kind == kind).map((r) => r.value).firstOrNull;
    return DailyVitals(
      restingHr: v('rhr'),
      hrDay: v('hr_day'),
      sleepMin: v('sleep_min'),
      sleepScore: v('sleep_score'),
      steps: v('steps'),
      vo2max: v('vo2max'),
      activeKcal: v('active_kcal'),
    );
  }

  Stream<DailyVitals> watchVitals(String date) => db
      .customSelect('SELECT 1', readsFrom: {db.healthSamples})
      .watch()
      .asyncMap((_) => vitalsFor(date));
}
