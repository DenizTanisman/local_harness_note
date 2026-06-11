import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/seed_data.dart';
import 'package:daily_tracker/data/heatmap/heatmap_rule.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('seed data (phase 0 acceptance)', () {
    test('seeds exactly 12 metrics', () async {
      final metrics = await db.select(db.metrics).get();
      expect(metrics, hasLength(12));
    });

    test('the 9 core heatmap metrics are starred, dev children are not',
        () async {
      final metrics = await db.select(db.metrics).get();
      final starred = metrics.where((m) => m.isStarred).map((m) => m.key);
      expect(starred, unorderedEquals(coreHeatmapOrder));
    });

    test('Brushing has 3 options, Waste has 1', () async {
      final metrics = await db.select(db.metrics).get();
      final byKey = {for (final m in metrics) m.key: m};
      final options = await db.select(db.metricOptions).get();

      final brushing =
          options.where((o) => o.metricId == byKey['brushing']!.id);
      expect(brushing.map((o) => o.label),
          orderedEquals(['Morning', 'Noon', 'Evening']));

      final waste = options.where((o) => o.metricId == byKey['waste']!.id);
      expect(waste, hasLength(1));
    });

    test('development children are linked via parent_id', () async {
      final metrics = await db.select(db.metrics).get();
      final byKey = {for (final m in metrics) m.key: m};
      final devId = byKey['development']!.id;
      for (final key in ['dev_marketing', 'dev_leadership', 'dev_social']) {
        expect(byKey[key]!.parentId, devId, reason: '$key parent');
      }
    });

    test('every starred metric has a parseable heatmap rule', () async {
      final metrics = await db.select(db.metrics).get();
      for (final metric in metrics.where((m) => m.isStarred)) {
        expect(metric.heatmapRule, isNotNull, reason: metric.key);
        final rule = HeatmapRule.decode(metric.heatmapRule!);
        expect(rule.buckets, isNotEmpty, reason: metric.key);
      }
    });

    test('money categories seeded with correct flags', () async {
      final categories = await db.select(db.moneyCategories).get();
      expect(categories, hasLength(5));
      final byName = {for (final c in categories) c.name: c};
      expect(byName['Rent']!.isEssential, isTrue);
      expect(byName['Bill']!.isEssential, isTrue);
      expect(byName['Food']!.countsInHeatmap, isTrue);
      expect(byName['Entertainment']!.countsInHeatmap, isTrue);
      expect(byName['Scholarship']!.direction, 'income');
      expect(byName['Food']!.isEssential, isFalse);
    });

    test('default settings seeded', () async {
      final settings = await db.select(db.appSettings).get();
      final map = {for (final s in settings) s.key: s.value};
      expect(map['morning_time'], '08:00');
      expect(map['evening_time'], '22:00');
      expect(map['quote_lang'], 'tr');
    });
  });

  group('entries UNIQUE(metric_id, date)', () {
    test('upsert on same day updates instead of duplicating', () async {
      final software = await (db.select(db.metrics)
            ..where((m) => m.key.equals('software')))
          .getSingle();
      final now = DateTime.now().millisecondsSinceEpoch;

      Future<void> upsert(double value) =>
          db.upsertEntry(EntriesCompanion.insert(
            metricId: software.id,
            date: '2026-06-10',
            numValue: Value(value),
            createdAt: now,
            updatedAt: now,
          ));

      await upsert(30);
      await upsert(45);

      final rows = await (db.select(db.entries)
            ..where((e) => e.metricId.equals(software.id)))
          .get();
      expect(rows, hasLength(1));
      expect(rows.single.numValue, 45);
    });

    test('plain double insert on same day throws', () async {
      final water = await (db.select(db.metrics)
            ..where((m) => m.key.equals('water')))
          .getSingle();
      final now = DateTime.now().millisecondsSinceEpoch;

      final companion = EntriesCompanion.insert(
        metricId: water.id,
        date: '2026-06-10',
        numValue: const Value(2),
        createdAt: now,
        updatedAt: now,
      );
      await db.into(db.entries).insert(companion);
      expect(() => db.into(db.entries).insert(companion), throwsException);
    });
  });

  group('cascade delete', () {
    test('deleting a metric removes its entries and options', () async {
      final brushing = await (db.select(db.metrics)
            ..where((m) => m.key.equals('brushing')))
          .getSingle();
      final now = DateTime.now().millisecondsSinceEpoch;
      final entryId = await db.into(db.entries).insert(EntriesCompanion.insert(
            metricId: brushing.id,
            date: '2026-06-10',
            createdAt: now,
            updatedAt: now,
          ));
      final option = await (db.select(db.metricOptions)
            ..where((o) => o.metricId.equals(brushing.id)))
          .get();
      await db.into(db.entryOptions).insert(EntryOptionsCompanion.insert(
          entryId: entryId, optionId: option.first.id));

      await (db.delete(db.metrics)..where((m) => m.id.equals(brushing.id)))
          .go();

      expect(await db.select(db.entries).get(),
          isNot(contains(predicate<Entry>((e) => e.metricId == brushing.id))));
      expect(
          await (db.select(db.metricOptions)
                ..where((o) => o.metricId.equals(brushing.id)))
              .get(),
          isEmpty);
      expect(await db.select(db.entryOptions).get(), isEmpty);
    });
  });
}
