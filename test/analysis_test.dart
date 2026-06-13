import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/repositories/analysis_repository.dart';
import 'package:daily_tracker/data/repositories/entry_repository.dart';
import 'package:daily_tracker/data/repositories/tree_repository.dart';
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

  Future<void> addTx(
    String date,
    String direction,
    String category,
    double amount,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            date: date,
            direction: direction,
            amount: amount,
            category: category,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  test('core 9 rows in fixed spec order', () async {
    final rows = await analysis.starredInDisplayOrder();
    expect(rows.map((m) => m.key), [
      'software',
      'development',
      'money',
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
      expect(rows.map((m) => m.key).skip(9), ['pushups', 'reading']);
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
      expect(matrix.rules[dev.id]!.colorFor(2), 'yellow');
    });

    test(
      'tx_sum_heatmap sums only counts_in_heatmap outcome categories',
      () async {
        await addTx('2026-06-09', 'outcome', 'Food', 200);
        await addTx('2026-06-09', 'outcome', 'Entertainment', 150);
        await addTx('2026-06-09', 'outcome', 'Rent', 8000); // not counted
        await addTx(
          '2026-06-09',
          'income',
          'Scholarship',
          15000,
        ); // not counted

        final money = await byKey('money');
        final matrix = await analysis.loadHeatmap('2026-06-10', 7);
        expect(matrix.values[money.id]!['2026-06-09'], 350);
        expect(matrix.rules[money.id]!.colorFor(350), 'green');
      },
    );

    test(
      'a day with only essential outcome is filled with sum 0 (darkGreen)',
      () async {
        await addTx('2026-06-09', 'outcome', 'Rent', 8000);
        final money = await byKey('money');
        final matrix = await analysis.loadHeatmap('2026-06-10', 7);
        expect(matrix.values[money.id]!['2026-06-09'], 0);
        expect(matrix.rules[money.id]!.colorFor(0), 'darkGreen');
      },
    );
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
      'Money line: day total is ALL outcome; month blocks by category',
      () async {
        await addTx('2026-06-09', 'outcome', 'Food', 340);
        await addTx('2026-06-09', 'outcome', 'Rent', 200);
        await addTx('2026-06-01', 'outcome', 'Rent', 8000);
        await addTx('2026-06-02', 'income', 'Scholarship', 15000);

        final items = await analysis.loadBreakdown('2026-06-09');
        final money = items.firstWhere((i) => i.id == 'money');
        expect(money.title, 'Money: 540 TL'); // not heatmap-filtered
        final outcome = money.children.firstWhere(
          (n) => n.id == 'money/outcome',
        );
        final income = money.children.firstWhere((n) => n.id == 'money/income');
        expect(outcome.title, 'Outcome (Month): 8.540');
        expect(income.title, 'Income (Month): 15.000');
        expect(outcome.children.map((n) => n.title), contains('Rent: 8.200'));
        expect(
          income.children.map((n) => n.title),
          contains('Scholarship: 15.000'),
        );
      },
    );

    test('money subtype appears as a third level (CR1-A)', () async {
      await addTx('2026-06-09', 'outcome', 'Bill', 2000);
      final now = DateTime.now().millisecondsSinceEpoch;
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              date: '2026-06-09',
              direction: 'outcome',
              amount: 500,
              category: 'Bill',
              subtype: const Value('home'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final items = await analysis.loadBreakdown('2026-06-09');
      final money = items.firstWhere((i) => i.id == 'money');
      final outcome = money.children.firstWhere((n) => n.id == 'money/outcome');
      final bill = outcome.children.firstWhere(
        (n) => n.title.startsWith('Bill'),
      );
      expect(bill.title, 'Bill: 2.500'); // category-level total
      expect(bill.children.single.title, 'Bill (home): 500');
    });

    test('metrics without entries that day are omitted', () async {
      final items = await analysis.loadBreakdown('2026-06-09');
      // Money is always present (day total 0); everything else omitted.
      expect(items.where((i) => i.id != 'money'), isEmpty);
    });
  });

  group('formatAmount', () {
    test('thousands separators, decimals only when fractional', () {
      expect(formatAmount(0), '0');
      expect(formatAmount(540), '540');
      expect(formatAmount(8200), '8.200');
      expect(formatAmount(12300), '12.300');
      expect(formatAmount(1234567), '1.234.567');
      expect(formatAmount(99.5), '99,50');
    });
  });
}
