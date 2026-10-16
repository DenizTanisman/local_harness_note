import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/heatmap/heatmap_rule.dart';
import 'package:local_harness_not/data/repositories/tree_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 2 acceptance (repository level): re-parenting, 2-level limit,
/// promotion to composite, detach, reorder, star defaults.
void main() {
  late AppDatabase db;
  late TreeRepository tree;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    tree = TreeRepository(db);
  });
  tearDown(() => db.close());

  Future<Metric> byKey(String key) =>
      (db.select(db.metrics)..where((m) => m.key.equals(key))).getSingle();

  group('makeChildOf', () {
    test(
      'leaf target is promoted to composite and child re-parented',
      () async {
        final water = await byKey('water');
        final sport = await byKey('sport');

        expect(await tree.canBecomeChildOf(water, sport), isTrue);
        await tree.makeChildOf(childId: water.id, parentId: sport.id);

        final sportAfter = await byKey('sport');
        final waterAfter = await byKey('water');
        expect(sportAfter.inputType, 'composite');
        expect(waterAfter.parentId, sport.id);
      },
    );

    test('composite target stays composite', () async {
      final extra = await byKey('extra');
      final dev = await byKey('development');
      expect(await tree.canBecomeChildOf(extra, dev), isTrue);
      await tree.makeChildOf(childId: extra.id, parentId: dev.id);
      expect((await byKey('development')).inputType, 'composite');
      expect((await byKey('extra')).parentId, dev.id);
    });

    test(
      'a group cannot be dropped into another card (2-level limit)',
      () async {
        final dev = await byKey('development'); // has 3 children
        final sport = await byKey('sport');
        expect(await tree.canBecomeChildOf(dev, sport), isFalse);
      },
    );

    test('a card cannot be dropped onto an existing child', () async {
      final marketing = await byKey('dev_marketing'); // already a child
      final extra = await byKey('extra');
      expect(await tree.canBecomeChildOf(extra, marketing), isFalse);
    });
  });

  group('detach', () {
    test('child returns to root at the end of the list', () async {
      final marketing = await byKey('dev_marketing');
      await tree.detach(marketing.id);

      final after = await byKey('dev_marketing');
      expect(after.parentId, isNull);

      final top = await (db.select(
        db.metrics,
      )..where((m) => m.parentId.isNull())).get();
      final maxOrder = top
          .map((m) => m.sortOrder)
          .reduce((a, b) => a > b ? a : b);
      expect(after.sortOrder, maxOrder);
    });
  });

  group('moveToRootPosition', () {
    test('reorders top-level cards contiguously', () async {
      final water = await byKey('water'); // last by seed order
      await tree.moveToRootPosition(water.id, 0);

      final top =
          await (db.select(db.metrics)
                ..where((m) => m.parentId.isNull())
                ..orderBy([(m) => OrderingTerm.asc(m.sortOrder)]))
              .get();
      expect(top.first.key, 'water');
      expect(top.map((m) => m.sortOrder), List.generate(top.length, (i) => i));
    });

    test('detaches a child when dropped into a gap', () async {
      final marketing = await byKey('dev_marketing');
      await tree.moveToRootPosition(marketing.id, 2);
      final after = await byKey('dev_marketing');
      expect(after.parentId, isNull);
      final top =
          await (db.select(db.metrics)
                ..where((m) => m.parentId.isNull())
                ..orderBy([(m) => OrderingTerm.asc(m.sortOrder)]))
              .get();
      expect(top[2].key, 'dev_marketing');
    });
  });

  group('star flow', () {
    test(
      'starring an ADD-created int metric gets the blue default rule',
      () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final id = await db
            .into(db.metrics)
            .insert(
              MetricsCompanion.insert(
                key: 'pushups',
                title: 'Pushups',
                inputType: 'int',
                createdAt: now,
                updatedAt: now,
              ),
            );
        final metric = await (db.select(
          db.metrics,
        )..where((m) => m.id.equals(id))).getSingle();

        await tree.star(metric, 'Pushups');

        final starred = await (db.select(
          db.metrics,
        )..where((m) => m.id.equals(id))).getSingle();
        expect(starred.isStarred, isTrue);
        expect(starred.heatmapLabel, 'Pushups');
        final rule = HeatmapRule.decode(starred.heatmapRule!);
        expect(rule.source, HeatmapSource.numValue);
        expect(rule.colorFor(50), 'blue');
      },
    );

    test('unstar keeps rule, label and history', () async {
      final software = await byKey('software');
      await tree.unstar(software.id);
      final after = await byKey('software');
      expect(after.isStarred, isFalse);
      expect(after.heatmapRule, isNotNull);
      expect(after.heatmapLabel, isNotNull);
    });

    test('re-star keeps an existing custom rule', () async {
      final software = await byKey('software');
      final ruleBefore = software.heatmapRule;
      await tree.unstar(software.id);
      await tree.star(await byKey('software'), 'Code');
      final after = await byKey('software');
      expect(after.heatmapRule, ruleBefore);
      expect(after.heatmapLabel, 'Code');
    });

    test('default rules per input type parse and use the right source', () {
      expect(
        HeatmapRule.decode(defaultRuleFor('text')).source,
        HeatmapSource.textExists,
      );
      expect(
        HeatmapRule.decode(defaultRuleFor('checkbox')).source,
        HeatmapSource.optionCount,
      );
      expect(
        HeatmapRule.decode(defaultRuleFor('composite')).source,
        HeatmapSource.filledSubcount,
      );
      expect(
        HeatmapRule.decode(defaultRuleFor('int')).source,
        HeatmapSource.numValue,
      );
      expect(
        HeatmapRule.decode(defaultRuleFor('int_text')).source,
        HeatmapSource.numValue,
      );
    });
  });
}
