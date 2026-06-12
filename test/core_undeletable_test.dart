import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/database_provider.dart';
import 'package:daily_tracker/data/db/seed_data.dart';
import 'package:daily_tracker/data/repositories/entry_repository.dart';
import 'package:daily_tracker/features/home/home_page.dart';
import 'package:daily_tracker/features/home/home_providers.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR-2 acceptance: the 12 seed metrics cannot be deleted — no Del button,
/// repository refuses, history intact; ADD-created metrics unchanged;
/// existing installs migrated by key.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('seed (fresh install)', () {
    test('all 12 core records seeded with is_deletable = 0', () async {
      final metrics = await db.select(db.metrics).get();
      expect(metrics, hasLength(12));
      expect(coreMetricKeys, hasLength(12));
      for (final metric in metrics) {
        expect(metric.isDeletable, isFalse, reason: metric.key);
      }
    });

    test('core keys cover the 9 heatmap rows + dev children', () {
      expect(
        coreMetricKeys,
        unorderedEquals([
          'software',
          'development',
          'money',
          'extra',
          'instagram',
          'sport',
          'brushing',
          'waste',
          'water',
          'dev_marketing',
          'dev_leadership',
          'dev_social',
        ]),
      );
    });
  });

  group('repository defence layer', () {
    test(
      'deleting a core metric is refused; record and history stay',
      () async {
        final repo = EntryRepository(db);
        final water = await (db.select(
          db.metrics,
        )..where((m) => m.key.equals('water'))).getSingle();
        await repo.saveEntry(
          metricId: water.id,
          date: '2026-06-10',
          numValue: 2,
        );

        await expectLater(
          repo.deleteMetric(water.id),
          throwsA(isA<StateError>()),
        );

        expect(
          await (db.select(
            db.metrics,
          )..where((m) => m.key.equals('water'))).getSingleOrNull(),
          isNotNull,
        );
        final entries = await (db.select(
          db.entries,
        )..where((e) => e.metricId.equals(water.id))).get();
        expect(entries, hasLength(1), reason: 'history must stay');
      },
    );

    test('ADD-created metric still deletes', () async {
      final repo = EntryRepository(db);
      final id = await repo.addMetric(title: 'Reading', inputType: 'int');
      await repo.deleteMetric(id);
      expect(
        await (db.select(
          db.metrics,
        )..where((m) => m.id.equals(id))).getSingleOrNull(),
        isNull,
      );
    });
  });

  group('v1 → v2 migration (existing installs)', () {
    test('markCoreUndeletable flips the core 12 by key, not id', () async {
      // Simulate a v1 install: core rows still deletable, user metric too,
      // and the user has reordered (ids irrelevant).
      await (db.update(
        db.metrics,
      )).write(const MetricsCompanion(isDeletable: Value(true)));
      final userId = await EntryRepository(
        db,
      ).addMetric(title: 'Reading', inputType: 'int');

      await db.markCoreUndeletable();

      final metrics = await db.select(db.metrics).get();
      for (final metric in metrics) {
        if (metric.id == userId) {
          expect(metric.isDeletable, isTrue, reason: 'user metric untouched');
        } else {
          expect(metric.isDeletable, isFalse, reason: metric.key);
        }
      }
    });
  });

  group('UI', () {
    late ProviderContainer container;

    Widget app() {
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          debounceDurationProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);
      return UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomePage()),
      );
    }

    Future<void> closeApp(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('no Del button on any core card; ADD metric shows one', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      // 9 core cards on screen, zero Del buttons.
      expect(find.text('Del'), findsNothing);

      await EntryRepository(db).addMetric(title: 'Reading', inputType: 'int');
      await tester.pumpAndSettle();

      expect(find.text('Del'), findsOneWidget);

      // And it works end-to-end with the confirm dialog.
      await tester.ensureVisible(find.text('Del'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Del'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(
        await (db.select(
          db.metrics,
        )..where((m) => m.key.equals('reading'))).getSingleOrNull(),
        isNull,
      );
      await closeApp(tester);
    });
  });
}
