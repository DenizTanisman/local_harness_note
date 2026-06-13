import 'package:drift/drift.dart';

import '../../core/date_key.dart';

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

/// Device source of fetched vitals (CR-3 §9 / P4). UI never talks to it.
abstract class HealthSource {
  Future<bool> isAvailable();

  /// True when Health Connect is missing or too old to use — the UI then
  /// offers [install] instead of a permission request.
  Future<bool> needsInstall();

  /// Sends the user to the store to install / update Health Connect.
  Future<void> install();

  Future<bool> hasPermission();
  Future<bool> requestPermission();

  /// kind → value for [day] ('rhr','hr_day','sleep_min','steps',
  /// 'active_kcal', 'vo2max'); null when unavailable.
  Future<Map<String, double>?> fetchDay(DateTime day);
}

/// DB-backed health profile + body log + sensor reads/sync. With a
/// [source] wired (P4), `sync` pulls Health Connect into `health_samples`;
/// without it (or without permission), `vitalsFor` stays empty → '—'.
class HealthRepository {
  HealthRepository(this.db, {this.source});

  final AppDatabase db;
  final HealthSource? source;

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

  // ---------- sensors (P4 Health Connect) ----------

  Future<bool> sensorAvailable() async => source?.isAvailable() ?? false;
  Future<bool> sensorNeedsInstall() async => source?.needsInstall() ?? false;
  Future<void> installSensor() async => source?.install();
  Future<bool> sensorPermission() async => source?.hasPermission() ?? false;

  /// Requests Health Connect access, then pulls today (or [day]).
  Future<bool> requestAndSync({DateTime? day}) async {
    if (source == null) return false;
    final granted = await source!.requestPermission();
    if (!granted) return false;
    await sync(day: day);
    return true;
  }

  /// Pulls [day] from the source into health_samples. Silent no-op without
  /// a source or permission (CR-3 §9).
  Future<void> sync({DateTime? day}) async {
    final src = source;
    if (src == null || !await src.hasPermission()) return;
    final d = day ?? DateTime.now();
    final map = await src.fetchDay(d);
    if (map == null || map.isEmpty) return;
    await storeSamples(dateKey(d), map, sourceTag: 'health_connect');
  }

  /// Upserts fetched vitals for a day (testable with any source).
  Future<void> storeSamples(
    String date,
    Map<String, double> values, {
    String sourceTag = 'health_connect',
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      for (final entry in values.entries) {
        await db
            .into(db.healthSamples)
            .insertOnConflictUpdate(
              HealthSamplesCompanion(
                date: Value(date),
                kind: Value(entry.key),
                value: Value(entry.value),
                source: Value(sourceTag),
                fetchedAt: Value(now),
              ),
            );
      }
    });
  }

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
