import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/repositories/analysis_repository.dart';
import 'package:local_harness_not/data/repositories/entry_repository.dart';
import 'package:local_harness_not/data/repositories/tree_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 3 acceptance (repository level): fixed core row order, value
/// sources, newly starred metrics appended, breakdown contents.
void main() {
  late AppDatabase db;
  late AnalysisRepository analysis;
  late EntryRepository entries;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    analysis = AnalysisRepository(db);
    entries = EntryRepository(db);
  });
  tearDown(() => db.close());

  Future<Metric> byKey(String key) =>
      (db.select(db.metrics)..where((m) => m.key.equals(key))).getSingle();

  test('core 8 rows in fixed spec order (money moved to Para)', () async {
    final rows = await analysis.starredInDisplayOrder();
    expect(rows.map((m) => m.key), [
      'software',
      'development',
      'extra',
      'instagram',
      'sport',
      'brushing',
      'waste',
      'water',
    ]);
  });

  test(
    'newly starred metric appends below the core rows in star order',
    () async {
      final tree = TreeRepository(db);
      final readingId = await entries.addMetric(
        title: 'Reading',
        inputType: 'int',
      );
      final pushupsId = await entries.addMetric(
        title: 'Pushups',
        inputType: 'int',
      );
      final pushups = await (db.select(
        db.metrics,
      )..where((m) => m.id.equals(pushupsId))).getSingle();
      await tree.star(pushups, 'Pushups');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final reading = await (db.select(
        db.metrics,
      )..where((m) => m.id.equals(readingId))).getSingle();
      await tree.star(reading, 'Reading');

      final rows = await analysis.starredInDisplayOrder();
      expect(rows.map((m) => m.key).skip(8), ['pushups', 'reading']);
    },
  );

  group('heatmap value sources', () {
    test(
      'num_value: entered day keeps its value; empty days count as 0',
      () async {
        final software = await byKey('software');
        await entries.saveEntry(
          metricId: software.id,
          date: '2026-06-08',
          numValue: 35,
        );

        final matrix = await analysis.loadHeatmap('2026-06-10', 7);
        final values = matrix.values[software.id]!;
        expect(values['2026-06-08'], 35);
        // End-of-day-zero: empty days are present as 0, not absent.
        expect(values['2026-06-09'], 0);
        expect(values.length, 7); // every day in the window
        expect(
          matrix.rules[software.id]!.colorFor(values['2026-06-08']!),
          'lightBlue',
        ); // spec: 35 is NOT blue
        expect(matrix.rules[software.id]!.colorFor(0), 'black'); // 0 → black
      },
    );

    test(
      'option_count counts selected checkboxes (0 when entry empty)',
      () async {
        final brushing = await byKey('brushing');
        final options = await (db.select(
          db.metricOptions,
        )..where((o) => o.metricId.equals(brushing.id))).get();
        for (final option in options.take(2)) {
          await entries.setOptionSelected(
            metricId: brushing.id,
            optionId: option.id,
            date: '2026-06-09',
            selected: true,
          );
        }

        final matrix = await analysis.loadHeatmap('2026-06-10', 7);
        expect(matrix.values[brushing.id]!['2026-06-09'], 2);
      },
    );

    test('text_exists is 1 only for non-empty text', () async {
      final extra = await byKey('extra');
      await entries.saveEntry(
        metricId: extra.id,
        date: '2026-06-08',
        textValue: 'read a paper',
      );
      await entries.saveEntry(
        metricId: extra.id,
        date: '2026-06-09',
        textValue: '   ',
      );

      final matrix = await analysis.loadHeatmap('2026-06-10', 7);
      final values = matrix.values[extra.id]!;
      expect(values['2026-06-08'], 1);
      expect(values['2026-06-09'], 0);
    });

    test('filled_subcount counts filled children', () async {
      final dev = await byKey('development');
      final marketing = await byKey('dev_marketing');
      final social = await byKey('dev_social');
      await entries.saveEntry(
        metricId: marketing.id,
        date: '2026-06-09',
        textValue: 'campaign',
      );
      await entries.saveEntry(
        metricId: social.id,
        date: '2026-06-09',
        textValue: 'meetup',
      );

      final matrix = await analysis.loadHeatmap('2026-06-10', 7);
      expect(matrix.values[dev.id]!['2026-06-09'], 2);
      expect(matrix.rules[dev.id]!.colorFor(2), 'blue');
    });
  });

  group('daily breakdown', () {
    test('Development lists only filled sub-titles', () async {
      final marketing = await byKey('dev_marketing');
      await entries.saveEntry(
        metricId: marketing.id,
        date: '2026-06-09',
        textValue: 'ads',
      );

      final items = await analysis.loadBreakdown('2026-06-09');
      final dev = items.firstWhere((i) => i.id == 'development');
      expect(dev.title, 'Development: Marketing');
      final child = dev.children.single;
      expect(child.title, 'Marketing');
      expect(child.children.single.title, 'ads');
    });

    test('group_display own_value shows the group entry instead', () async {
      final dev = await byKey('development');
      await (db.update(db.metrics)..where((m) => m.id.equals(dev.id))).write(
        const MetricsCompanion(groupDisplay: Value('own_value')),
      );
      await entries.saveEntry(
        metricId: dev.id,
        date: '2026-06-09',
        textValue: 'busy day',
      );
      final marketing = await byKey('dev_marketing');
      await entries.saveEntry(
        metricId: marketing.id,
        date: '2026-06-09',
        textValue: 'ads',
      );

      final items = await analysis.loadBreakdown('2026-06-09');
      final item = items.firstWhere((i) => i.id == 'development');
      expect(item.title, 'Development: ✓');
    });

    test(
      'int_text root shows value + unit; its note is a child leaf',
      () async {
        final software = await byKey('software');
        await entries.saveEntry(
          metricId: software.id,
          date: '2026-06-09',
          numValue: 45,
          textValue: 'parser',
        );
        final items = await analysis.loadBreakdown('2026-06-09');
        final item = items.single;
        expect(item.title, 'Software: 45 min');
        expect(item.children.single.title, 'parser');
        expect(item.children.single.inlineExpand, isTrue);
      },
    );

    test('metrics without entries that day are omitted', () async {
      // No always-present Money row any more: an empty day is empty.
      expect(await analysis.loadBreakdown('2026-06-09'), isEmpty);
    });
  });
}
