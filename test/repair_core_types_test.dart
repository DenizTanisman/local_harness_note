import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/repositories/entry_repository.dart';
import 'package:daily_tracker/data/repositories/tree_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// v4 repair: cards promoted to composite BEFORE prev_input_type existed
/// (e.g. Waste stuck as an unusable empty group) get their seed type back.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<Metric> byKey(String key) =>
      (db.select(db.metrics)..where((m) => m.key.equals(key))).getSingle();

  /// Simulate pre-v3 damage: composite with NO promotion memory.
  Future<void> damage(String key) async {
    final metric = await byKey(key);
    await (db.update(db.metrics)..where((m) => m.id.equals(metric.id))).write(
      const MetricsCompanion(
        inputType: Value('composite'),
        prevInputType: Value(null),
      ),
    );
  }

  test('childless damaged Waste is restored to checkbox', () async {
    await damage('waste');
    await db.repairCorruptedCoreTypes();

    final waste = await byKey('waste');
    expect(waste.inputType, 'checkbox');
    expect(waste.prevInputType, isNull);
    // Its options were never touched — the card is fully usable again.
    final options = await (db.select(
      db.metricOptions,
    )..where((o) => o.metricId.equals(waste.id))).get();
    expect(options, hasLength(1));
  });

  test('every damaged childless core leaf returns to its seed type', () async {
    for (final key in ['software', 'water', 'extra', 'brushing', 'sport']) {
      await damage(key);
    }
    await db.repairCorruptedCoreTypes();

    expect((await byKey('software')).inputType, 'int_text');
    expect((await byKey('water')).inputType, 'int');
    expect((await byKey('extra')).inputType, 'text');
    expect((await byKey('brushing')).inputType, 'checkbox');
    expect((await byKey('sport')).inputType, 'int_text');
  });

  test('damaged composite that still has children keeps the group but '
      'gains promotion memory for the next detach', () async {
    final tree = TreeRepository(db);
    final waste = await byKey('waste');
    final extra = await byKey('extra');
    // Pre-v3 style: child attached, no memory.
    await tree.makeChildOf(childId: extra.id, parentId: waste.id);
    await (db.update(db.metrics)..where((m) => m.id.equals(waste.id))).write(
      const MetricsCompanion(prevInputType: Value(null)),
    ); // wipe memory

    await db.repairCorruptedCoreTypes();

    var repaired = await byKey('waste');
    expect(repaired.inputType, 'composite', reason: 'child still inside');
    expect(repaired.prevInputType, 'checkbox', reason: 'memory restored');

    await tree.detach(extra.id);
    repaired = await byKey('waste');
    expect(
      repaired.inputType,
      'checkbox',
      reason: 'detach now restores thanks to repaired memory',
    );
  });

  test('development (natural composite) and healthy cards untouched', () async {
    final before = {
      for (final m in await db.select(db.metrics).get()) m.key: m.inputType,
    };
    await db.repairCorruptedCoreTypes();
    final after = {
      for (final m in await db.select(db.metrics).get()) m.key: m.inputType,
    };
    expect(after, before);
  });

  test('user-created metrics are left alone', () async {
    final entries = EntryRepository(db);
    final id = await entries.addMetric(title: 'Reading', inputType: 'int');
    await (db.update(db.metrics)..where((m) => m.id.equals(id))).write(
      const MetricsCompanion(inputType: Value('composite')),
    );

    await db.repairCorruptedCoreTypes();

    final reading = await (db.select(
      db.metrics,
    )..where((m) => m.id.equals(id))).getSingle();
    expect(
      reading.inputType,
      'composite',
      reason: 'non-core types are unknown; repair only covers the seed',
    );
  });
}
