import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/database_provider.dart';
import 'package:daily_tracker/data/repositories/entry_repository.dart';
import 'package:daily_tracker/data/repositories/tree_repository.dart';
import 'package:daily_tracker/features/home/home_page.dart';
import 'package:daily_tracker/features/home/home_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bugfix: a leaf promoted to composite by a drop must return to its
/// ORIGINAL input type when its last child leaves — by detach, reorder,
/// re-parent or child deletion. Natural composites stay composite.
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

  test('promotion remembers the original type', () async {
    final water = await byKey('water');
    final sport = await byKey('sport'); // int_text leaf
    await tree.makeChildOf(childId: water.id, parentId: sport.id);

    final promoted = await byKey('sport');
    expect(promoted.inputType, 'composite');
    expect(promoted.prevInputType, 'int_text');
  });

  test('detach of the last child restores the original type', () async {
    final water = await byKey('water');
    final sport = await byKey('sport');
    await tree.makeChildOf(childId: water.id, parentId: sport.id);
    await tree.detach(water.id);

    final restored = await byKey('sport');
    expect(restored.inputType, 'int_text');
    expect(restored.prevInputType, isNull);
    expect((await byKey('water')).parentId, isNull);
  });

  test('with two children, demotion waits for the LAST one', () async {
    final water = await byKey('water');
    final extra = await byKey('extra');
    final sport = await byKey('sport');
    await tree.makeChildOf(childId: water.id, parentId: sport.id);
    await tree.makeChildOf(childId: extra.id, parentId: sport.id);

    await tree.detach(water.id);
    expect(
      (await byKey('sport')).inputType,
      'composite',
      reason: 'still has Extra',
    );

    await tree.detach(extra.id);
    expect((await byKey('sport')).inputType, 'int_text');
  });

  test('reorder-gap drop (moveToRootPosition) also restores', () async {
    final water = await byKey('water');
    final sport = await byKey('sport');
    await tree.makeChildOf(childId: water.id, parentId: sport.id);
    await tree.moveToRootPosition(water.id, 0);

    expect((await byKey('sport')).inputType, 'int_text');
  });

  test(
    're-parenting the only child to another card restores the old parent',
    () async {
      final water = await byKey('water');
      final sport = await byKey('sport');
      final instagram = await byKey('instagram');
      await tree.makeChildOf(childId: water.id, parentId: sport.id);
      await tree.makeChildOf(childId: water.id, parentId: instagram.id);

      expect(
        (await byKey('sport')).inputType,
        'int_text',
        reason: 'old parent demoted',
      );
      expect((await byKey('instagram')).inputType, 'composite');
      expect((await byKey('instagram')).prevInputType, 'int_text');
    },
  );

  test('deleting the last (user-created) child restores the parent', () async {
    final entries = EntryRepository(db);
    final readingId = await entries.addMetric(
      title: 'Reading',
      inputType: 'int',
    );
    final water = await byKey('water'); // int leaf target
    await tree.makeChildOf(childId: readingId, parentId: water.id);
    expect((await byKey('water')).inputType, 'composite');

    await entries.deleteMetric(readingId);
    expect((await byKey('water')).inputType, 'int');
    expect((await byKey('water')).prevInputType, isNull);
  });

  test('natural composite (Development) never demotes', () async {
    for (final key in ['dev_marketing', 'dev_leadership', 'dev_social']) {
      final child = await byKey(key);
      await tree.detach(child.id);
    }
    final dev = await byKey('development');
    expect(
      dev.inputType,
      'composite',
      reason: 'prev_input_type is NULL for natural groups',
    );
    expect(dev.prevInputType, isNull);
  });

  test('restored card keeps its history and heatmap rule', () async {
    final entries = EntryRepository(db);
    final sport = await byKey('sport');
    await entries.saveEntry(
      metricId: sport.id,
      date: '2026-06-10',
      numValue: 45,
    );
    final ruleBefore = sport.heatmapRule;

    final water = await byKey('water');
    await tree.makeChildOf(childId: water.id, parentId: sport.id);
    await tree.detach(water.id);

    final after = await byKey('sport');
    expect(after.heatmapRule, ruleBefore);
    final rows = await (db.select(
      db.entries,
    )..where((e) => e.metricId.equals(sport.id))).get();
    expect(rows, hasLength(1));
  });

  testWidgets('UI: Sport shows its number field again after ungrouping', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        debounceDurationProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);
    tester.view.physicalSize = const Size(1080, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final water = await byKey('water');
    final sport = await byKey('sport');
    await tree.makeChildOf(childId: water.id, parentId: sport.id);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    Finder sportCard() => find
        .ancestor(of: find.text('Sport'), matching: find.byType(Card))
        .first;
    // Promoted: chip visible, no TextField of its own.
    expect(
      find.descendant(
        of: sportCard(),
        matching: find.widgetWithText(FilterChip, 'Water'),
      ),
      findsOneWidget,
    );

    await tree.detach(water.id);
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: sportCard(), matching: find.byType(TextField)),
      findsOneWidget,
      reason: 'int_text number field is back',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  });
}
