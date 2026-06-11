import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// Tree mutations + star flow for the home page (spec §7, 6.2).
class TreeRepository {
  TreeRepository(this.db);

  final AppDatabase db;

  /// Whether [metric] may be dropped onto [target] to become its child.
  /// Max 2 levels: groups cannot be nested; money takes no part in the tree.
  Future<bool> canBecomeChildOf(Metric metric, Metric target) async {
    if (metric.id == target.id) return false;
    if (metric.inputType == 'money' || target.inputType == 'money') {
      return false;
    }
    if (target.parentId != null) return false; // target already a child
    if (metric.inputType == 'composite') return false; // group into group
    final children = await (db.select(
      db.metrics,
    )..where((m) => m.parentId.equals(metric.id))).get();
    return children.isEmpty; // a card with children is a group
  }

  /// Drop onto a card: re-parent and promote a leaf target to composite.
  Future<void> makeChildOf({required int childId, required int parentId}) {
    return db.transaction(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final parent = await (db.select(
        db.metrics,
      )..where((m) => m.id.equals(parentId))).getSingle();
      if (parent.inputType != 'composite') {
        await (db.update(
          db.metrics,
        )..where((m) => m.id.equals(parentId))).write(
          MetricsCompanion(
            inputType: const Value('composite'),
            updatedAt: Value(now),
          ),
        );
      }
      final siblingMax = db.metrics.sortOrder.max();
      final row =
          await (db.selectOnly(db.metrics)
                ..addColumns([siblingMax])
                ..where(db.metrics.parentId.equals(parentId)))
              .getSingle();
      await (db.update(db.metrics)..where((m) => m.id.equals(childId))).write(
        MetricsCompanion(
          parentId: Value(parentId),
          sortOrder: Value((row.read(siblingMax) ?? -1) + 1),
          updatedAt: Value(now),
        ),
      );
    });
  }

  /// Drag out of a group back to the root (end of the list).
  Future<void> detach(int childId) {
    return db.transaction(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final rootMax = db.metrics.sortOrder.max();
      final row =
          await (db.selectOnly(db.metrics)
                ..addColumns([rootMax])
                ..where(db.metrics.parentId.isNull()))
              .getSingle();
      await (db.update(db.metrics)..where((m) => m.id.equals(childId))).write(
        MetricsCompanion(
          parentId: const Value(null),
          sortOrder: Value((row.read(rootMax) ?? -1) + 1),
          updatedAt: Value(now),
        ),
      );
    });
  }

  /// Reorder mode drop into a gap: move [metricId] to [targetIndex] among
  /// the top-level cards (detaching it first if it was a child).
  Future<void> moveToRootPosition(int metricId, int targetIndex) {
    return db.transaction(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final top =
          await (db.select(db.metrics)
                ..where((m) => m.parentId.isNull())
                ..orderBy([(m) => OrderingTerm.asc(m.sortOrder)]))
              .get();
      final ids = top.map((m) => m.id).where((id) => id != metricId).toList();
      final clamped = targetIndex.clamp(0, ids.length);
      ids.insert(clamped, metricId);
      for (var i = 0; i < ids.length; i++) {
        await (db.update(db.metrics)..where((m) => m.id.equals(ids[i]))).write(
          MetricsCompanion(
            sortOrder: Value(i),
            parentId: const Value(null),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }

  /// Star flow (spec 6.2): label asked once; a sensible default rule is
  /// attached based on input type if the metric has none yet.
  Future<void> star(Metric metric, String heatmapLabel) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (db.update(db.metrics)..where((m) => m.id.equals(metric.id))).write(
      MetricsCompanion(
        isStarred: const Value(true),
        starredAt: Value(now),
        heatmapLabel: Value(heatmapLabel),
        heatmapRule: metric.heatmapRule == null
            ? Value(defaultRuleFor(metric.inputType))
            : const Value.absent(),
        updatedAt: Value(now),
      ),
    );
  }

  /// Unstar: drops off the heatmap, history untouched.
  Future<void> unstar(int metricId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (db.update(db.metrics)..where((m) => m.id.equals(metricId))).write(
      MetricsCompanion(isStarred: const Value(false), updatedAt: Value(now)),
    );
  }
}

/// Default heatmap rule template per input type (spec 6.2).
String defaultRuleFor(String inputType) {
  Map<String, dynamic> bucket(num min, num? max, String color) => {
    'min': min,
    'max': max,
    'color': color,
  };
  switch (inputType) {
    case 'text':
      return jsonEncode({
        'source': 'text_exists',
        'buckets': [bucket(0, 1, 'white'), bucket(1, null, 'orange')],
      });
    case 'checkbox':
      return jsonEncode({
        'source': 'option_count',
        'buckets': [
          bucket(0, 1, 'black'),
          bucket(1, 2, 'lightBlue'),
          bucket(2, 3, 'blue'),
          bucket(3, null, 'darkBlue'),
        ],
      });
    case 'composite':
      return jsonEncode({
        'source': 'filled_subcount',
        'buckets': [
          bucket(0, 1, 'black'),
          bucket(1, 2, 'lightYellow'),
          bucket(2, 3, 'yellow'),
          bucket(3, null, 'darkYellow'),
        ],
      });
    default: // int, int_text
      return jsonEncode({
        'source': 'num_value',
        'buckets': [
          bucket(0, 20, 'black'),
          bucket(20, 40, 'lightBlue'),
          bucket(40, 60, 'blue'),
          bucket(60, null, 'darkBlue'),
        ],
      });
  }
}
