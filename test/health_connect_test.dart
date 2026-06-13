import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/repositories/health_repository.dart';
import 'package:daily_tracker/features/health/health_connect_source.dart';
import 'package:drift/native.dart';
import 'package:health/health.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR3-P4 acceptance: aggregation mapping, permission-gated sync into
/// health_samples, vitalsFor round-trip, silent skip without permission.
class _FakeHealthSource implements HealthSource {
  _FakeHealthSource({this.granted = true, this.day});
  bool granted;
  Map<String, double>? day;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<bool> needsInstall() async => false;
  @override
  Future<void> install() async {}
  @override
  Future<bool> hasPermission() async => granted;
  @override
  Future<bool> requestPermission() async => granted;
  @override
  Future<Map<String, double>?> fetchDay(DateTime d) async => day;
}

void main() {
  group('aggregateReadings (pure)', () {
    test('avg HR/RHR, sum steps/kcal, sum sleep minutes', () {
      final out = aggregateReadings([
        (type: HealthDataType.RESTING_HEART_RATE, value: 58, minutes: 0),
        (type: HealthDataType.RESTING_HEART_RATE, value: 62, minutes: 0),
        (type: HealthDataType.HEART_RATE, value: 70, minutes: 0),
        (type: HealthDataType.HEART_RATE, value: 80, minutes: 0),
        (type: HealthDataType.STEPS, value: 4000, minutes: 0),
        (type: HealthDataType.STEPS, value: 3420, minutes: 0),
        (type: HealthDataType.ACTIVE_ENERGY_BURNED, value: 250, minutes: 0),
        (type: HealthDataType.SLEEP_ASLEEP, value: 0, minutes: 320),
        (type: HealthDataType.SLEEP_ASLEEP, value: 0, minutes: 120),
      ]);
      expect(out['rhr'], 60);
      expect(out['hr_day'], 75);
      expect(out['steps'], 7420);
      expect(out['active_kcal'], 250);
      expect(out['sleep_min'], 440);
    });

    test('absent types are omitted (no zero noise)', () {
      final out = aggregateReadings([
        (type: HealthDataType.STEPS, value: 100, minutes: 0),
      ]);
      expect(out.keys, ['steps']);
    });
  });

  group('HealthRepository sync', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('sync stores samples; vitalsFor reads them', () async {
      final repo = HealthRepository(
        db,
        source: _FakeHealthSource(
          day: {'rhr': 60, 'steps': 7420, 'sleep_min': 440, 'active_kcal': 250},
        ),
      );
      await repo.sync(day: DateTime(2026, 6, 13));
      final v = await repo.vitalsFor('2026-06-13');
      expect(v.restingHr, 60);
      expect(v.steps, 7420);
      expect(v.sleepMin, 440);
      expect(v.activeKcal, 250);
      expect(v.isEmpty, isFalse);
    });

    test('no permission → silent skip, nothing stored', () async {
      final repo = HealthRepository(
        db,
        source: _FakeHealthSource(granted: false, day: {'rhr': 60}),
      );
      await repo.sync(day: DateTime(2026, 6, 13));
      expect(await db.select(db.healthSamples).get(), isEmpty);
    });

    test('no source → sync is a no-op', () async {
      final repo = HealthRepository(db);
      await repo.sync(day: DateTime(2026, 6, 13));
      expect(await db.select(db.healthSamples).get(), isEmpty);
    });

    test('requestAndSync stores when granted', () async {
      final repo = HealthRepository(
        db,
        source: _FakeHealthSource(day: {'steps': 5000}),
      );
      final ok = await repo.requestAndSync(day: DateTime(2026, 6, 13));
      expect(ok, isTrue);
      expect((await repo.vitalsFor('2026-06-13')).steps, 5000);
    });
  });
}
