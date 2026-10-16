import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// How complete one day's Daily Check-in is. Counts TOP-LEVEL cards only; a
/// composite counts as filled when any child has an entry that day. Shared
/// by the evening reminder (missing count) and the hub snapshot.
class CheckinStatus {
  const CheckinStatus({required this.total, required this.missing});

  final int total;

  /// Unfilled top-level cards, in card order.
  final List<Metric> missing;

  int get filled => total - missing.length;
}

Future<CheckinStatus> loadCheckinStatus(AppDatabase db, String date) async {
  final metrics = await (db.select(
    db.metrics,
  )..orderBy([(m) => OrderingTerm.asc(m.sortOrder)])).get();
  final dayEntries = await (db.select(
    db.entries,
  )..where((e) => e.date.equals(date))).get();
  final filledIds = dayEntries.map((e) => e.metricId).toSet();

  final top = metrics.where((m) => m.parentId == null).toList();
  final missing = [
    for (final metric in top)
      if (!(metric.inputType == 'composite'
          ? metrics
                .where((c) => c.parentId == metric.id)
                .any((c) => filledIds.contains(c.id))
          : filledIds.contains(metric.id)))
        metric,
  ];
  return CheckinStatus(total: top.length, missing: missing);
}
