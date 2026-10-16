import 'dart:convert';

import 'package:local_harness_not/core/hub_bridge.dart';
import 'package:local_harness_not/core/hub_snapshot_publisher.dart';
import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/repositories/checkin_status.dart';
import 'package:local_harness_not/data/repositories/entry_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hub contract v1 §4/§5 (docs/HUB_CONTRACT.md): the `not` snapshot is a
/// pure function of the DB; the publisher pushes it at start and debounced
/// after writes; the bridge is a silent no-op without a platform side.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late EntryRepository entries;
  final now = DateTime(2026, 10, 4, 12, 30);
  const today = '2026-10-04';

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    entries = EntryRepository(db);
  });
  tearDown(() => db.close());

  Future<Metric> byKey(String key) =>
      (db.select(db.metrics)..where((m) => m.key.equals(key))).getSingle();

  group('buildHubSnapshot', () {
    test('envelope: app, schema, date, generatedAt, headline', () async {
      final snap = await buildHubSnapshot(db, now: now);
      expect(snap['app'], 'not');
      expect(snap['schema'], 1);
      expect(snap['date'], today);
      expect(snap['generatedAt'], '2026-10-04T12:30:00.000');
      expect(snap['headline'], 'Check-in 0/8 · 8 left');
      // Round-trips through JSON unchanged (what the hub will read).
      expect(jsonDecode(jsonEncode(snap)), snap);
    });

    test('empty day: nothing filled, every top-level card missing', () async {
      final data = (await buildHubSnapshot(db, now: now))['data'] as Map;
      final checkin = data['checkin'] as Map;
      expect(checkin['filled'], 0);
      expect(checkin['total'], 8);
      expect(checkin['missing'], [
        'Software',
        'Development',
        'Extra',
        'Instagram',
        'Sport',
        'Brushing',
        'Waste',
        'Water',
      ]);
      expect(data['today'], isEmpty);
    });

    test('today lists entries in tree order with value/text/options', () async {
      final software = await byKey('software');
      final leadership = await byKey('dev_leadership');
      final brushing = await byKey('brushing');
      final water = await byKey('water');
      await entries.saveEntry(
        metricId: software.id,
        date: today,
        numValue: 45,
        textValue: 'parser',
      );
      await entries.saveEntry(
        metricId: leadership.id,
        date: today,
        textValue: 'led standup',
      );
      final options = await (db.select(
        db.metricOptions,
      )..where((o) => o.metricId.equals(brushing.id))).get();
      // Select Evening, then Morning: output follows option order.
      for (final o in [options[2], options[0]]) {
        await entries.setOptionSelected(
          metricId: brushing.id,
          optionId: o.id,
          date: today,
          selected: true,
        );
      }
      // Another day must not leak into today.
      await entries.saveEntry(
        metricId: water.id,
        date: '2026-10-03',
        numValue: 2,
      );

      final snap = await buildHubSnapshot(db, now: now);
      final data = snap['data'] as Map;
      final checkin = data['checkin'] as Map;
      // Development counts as filled through its child.
      expect(checkin['filled'], 3);
      expect(checkin['total'], 8);
      expect(checkin['missing'], [
        'Extra',
        'Instagram',
        'Sport',
        'Waste',
        'Water',
      ]);
      expect(snap['headline'], 'Check-in 3/8 · 5 left');

      expect(data['today'], [
        {
          'key': 'software',
          'title': 'Software',
          'unit': 'min',
          'value': 45.0,
          'text': 'parser',
          'options': <String>[],
        },
        {
          'key': 'dev_leadership',
          'title': 'Leadership',
          'unit': null,
          'value': null,
          'text': 'led standup',
          'options': <String>[],
        },
        {
          'key': 'brushing',
          'title': 'Brushing',
          'unit': null,
          'value': null,
          'text': null,
          'options': ['Morning', 'Evening'],
        },
      ]);
    });

    test('all cards filled → "complete" headline', () async {
      final top = await (db.select(
        db.metrics,
      )..where((m) => m.parentId.isNull())).get();
      for (final metric in top) {
        final target = metric.inputType == 'composite'
            ? await byKey('dev_social')
            : metric;
        await entries.saveEntry(metricId: target.id, date: today, numValue: 1);
      }
      final snap = await buildHubSnapshot(db, now: now);
      expect(snap['headline'], 'Check-in complete · 8/8');
      expect(((snap['data'] as Map)['checkin'] as Map)['missing'], isEmpty);
    });
  });

  group('loadCheckinStatus (evening reminder count)', () {
    test('composite filled via any child; user metrics count too', () async {
      await entries.addMetric(title: 'Reading', inputType: 'int');
      await entries.saveEntry(
        metricId: (await byKey('dev_marketing')).id,
        date: today,
        textValue: 'ads',
      );
      final status = await loadCheckinStatus(db, today);
      expect(status.total, 9);
      expect(status.filled, 1);
      expect(status.missing.map((m) => m.key), contains('reading'));
      expect(status.missing.map((m) => m.key), isNot(contains('development')));
    });
  });

  group('HubSnapshotPublisher', () {
    test('publishes at start and again (debounced) after a write', () async {
      final published = <Map<String, Object?>>[];
      final publisher = HubSnapshotPublisher(
        db,
        debounce: const Duration(milliseconds: 20),
        publish: (s) async => published.add(s),
      );
      addTearDown(publisher.dispose);

      await publisher.start();
      expect(published, hasLength(1));

      final water = await byKey('water');
      // Two quick writes collapse into one publish.
      final date = published.single['date'] as String;
      await entries.saveEntry(metricId: water.id, date: date, numValue: 1);
      await entries.saveEntry(metricId: water.id, date: date, numValue: 2);
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(published, hasLength(2));
      final today = (published.last['data'] as Map)['today'] as List;
      expect((today.single as Map)['value'], 2.0);
    });

    test('a failing publish never throws out of the publisher', () async {
      final publisher = HubSnapshotPublisher(
        db,
        publish: (_) async => throw StateError('disk full'),
      );
      addTearDown(publisher.dispose);
      await publisher.publishNow();
    });
  });

  group('HubBridge without a platform side (widget tests)', () {
    test('every call degrades to a no-op / null / false', () async {
      await HubBridge.publishSnapshot({'app': 'not'});
      expect(await HubBridge.readPeerSnapshot('program'), isNull);
      expect(await HubBridge.isInstalled('program'), isFalse);
      expect(await HubBridge.launchApp('hub', route: '/'), isFalse);
    });
  });
}
