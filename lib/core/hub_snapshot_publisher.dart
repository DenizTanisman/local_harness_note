import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/app_database.dart';
import '../data/db/database_provider.dart';
import '../data/repositories/checkin_status.dart';
import 'date_key.dart';
import 'hub_bridge.dart';

/// Snapshot schema version served to the hub (docs/HUB_CONTRACT.md §4).
const hubSnapshotSchema = 1;

/// Builds the `not` hub snapshot (contract §4) — a pure function of the DB
/// so it is unit-testable with an in-memory database. [now] defaults to the
/// current time and decides which day counts as "today".
Future<Map<String, Object?>> buildHubSnapshot(
  AppDatabase db, {
  DateTime? now,
}) async {
  final at = now ?? DateTime.now();
  final date = dateKey(at);
  final status = await loadCheckinStatus(db, date);

  final metrics = await (db.select(
    db.metrics,
  )..orderBy([(m) => OrderingTerm.asc(m.sortOrder)])).get();
  final entries = await (db.select(
    db.entries,
  )..where((e) => e.date.equals(date))).get();
  final entryByMetric = {for (final e in entries) e.metricId: e};

  final optionJoin = db.select(db.entryOptions).join([
    innerJoin(db.entries, db.entries.id.equalsExp(db.entryOptions.entryId)),
    innerJoin(
      db.metricOptions,
      db.metricOptions.id.equalsExp(db.entryOptions.optionId),
    ),
  ])..where(db.entries.date.equals(date));
  final optionRows = await optionJoin.get();
  optionRows.sort(
    (a, b) => a
        .readTable(db.metricOptions)
        .sortOrder
        .compareTo(b.readTable(db.metricOptions).sortOrder),
  );
  final labelsByEntry = <int, List<String>>{};
  for (final row in optionRows) {
    labelsByEntry
        .putIfAbsent(row.readTable(db.entries).id, () => [])
        .add(row.readTable(db.metricOptions).label);
  }

  // Tree order: each top-level card, then its children (card order).
  final ordered = <Metric>[];
  for (final top in metrics.where((m) => m.parentId == null)) {
    ordered.add(top);
    ordered.addAll(metrics.where((m) => m.parentId == top.id));
  }

  final today = <Map<String, Object?>>[
    for (final metric in ordered)
      if (entryByMetric[metric.id] case final entry?)
        {
          'key': metric.key,
          'title': metric.title,
          'unit': metric.unit,
          'value': entry.numValue,
          'text': (entry.textValue?.trim().isEmpty ?? true)
              ? null
              : entry.textValue,
          'options': labelsByEntry[entry.id] ?? const <String>[],
        },
  ];

  final headline = status.total == 0
      ? 'No check-in metrics yet'
      : status.missing.isEmpty
      ? 'Check-in complete · ${status.filled}/${status.total}'
      : 'Check-in ${status.filled}/${status.total} · '
            '${status.missing.length} left';

  return {
    'app': 'not',
    'schema': hubSnapshotSchema,
    // Millisecond precision, local time (contract example format).
    'generatedAt': DateTime.fromMillisecondsSinceEpoch(
      at.millisecondsSinceEpoch,
    ).toIso8601String(),
    'date': date,
    'headline': headline,
    'data': {
      'checkin': {
        'filled': status.filled,
        'total': status.total,
        'missing': [for (final m in status.missing) m.title],
      },
      'today': today,
    },
  };
}

/// Keeps filesDir/hub_snapshot.json fresh (contract §5): once at startup,
/// debounced after every DB write, and when the app is backgrounded.
class HubSnapshotPublisher with WidgetsBindingObserver {
  HubSnapshotPublisher(
    this.db, {
    this.debounce = const Duration(milliseconds: 1500),
    Future<void> Function(Map<String, Object?> snapshot)? publish,
  }) : _publish = publish ?? HubBridge.publishSnapshot;

  final AppDatabase db;
  final Duration debounce;
  final Future<void> Function(Map<String, Object?> snapshot) _publish;

  StreamSubscription<Set<TableUpdate>>? _updates;
  Timer? _timer;
  bool _started = false;

  /// Publishes now and starts listening. Idempotent.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _updates = db.tableUpdates().listen((_) {
      _timer?.cancel();
      _timer = Timer(debounce, publishNow);
    });
    await publishNow();
  }

  Future<void> publishNow() async {
    _timer?.cancel();
    try {
      await _publish(await buildHubSnapshot(db));
    } catch (_) {
      // Best-effort: the hub just shows the previous snapshot. Never log
      // the payload (it carries the user's notes, spec §11.7).
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) publishNow();
  }

  void dispose() {
    _timer?.cancel();
    _updates?.cancel();
    if (_started) WidgetsBinding.instance.removeObserver(this);
  }
}

final hubSnapshotPublisherProvider = Provider<HubSnapshotPublisher>((ref) {
  final publisher = HubSnapshotPublisher(ref.watch(databaseProvider));
  ref.onDispose(publisher.dispose);
  return publisher;
});
