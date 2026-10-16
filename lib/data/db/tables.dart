import 'package:drift/drift.dart';

/// Metric tree: every card is a row — groups and leaves alike (ADR-2).
class Metrics extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get parentId => integer().nullable().references(
    Metrics,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get key => text().unique()();
  TextColumn get title => text()();

  /// 'int' | 'text' | 'int_text' | 'checkbox' | 'composite'
  TextColumn get inputType => text()();

  /// Original input type of a leaf that was auto-promoted to composite by
  /// a drop; restored when its last child detaches. NULL for natural
  /// composites (Development) and never-promoted cards.
  TextColumn get prevInputType => text().nullable()();
  BoolColumn get isStarred => boolean().withDefault(const Constant(false))();

  /// Epoch ms of the star action — later-starred metrics append below the
  /// fixed core rows in star order (spec 5.3).
  IntColumn get starredAt => integer().nullable()();
  TextColumn get heatmapLabel => text().nullable()();

  /// JSON bucket rule, see HeatmapRule.
  TextColumn get heatmapRule => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get unit => text().nullable()();
  BoolColumn get isDeletable => boolean().withDefault(const Constant(true))();

  /// 'sub_names' | 'own_value' — composite breakdown display (spec 6.3).
  TextColumn get groupDisplay =>
      text().withDefault(const Constant('sub_names'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}

/// Checkbox / multi-select options (Brushing → Morning/Noon/Evening).
class MetricOptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get metricId =>
      integer().references(Metrics, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Daily values: ONE row per metric × day.
class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get metricId =>
      integer().references(Metrics, #id, onDelete: KeyAction.cascade)();

  /// 'YYYY-MM-DD' local time.
  TextColumn get date => text()();
  RealColumn get numValue => real().nullable()();
  TextColumn get textValue => text().nullable()();

  /// 'manual' | 'auto' (CR-4 §3.3): a manual edit pins the day so the
  /// Instagram auto-fill (from the Program app's screen time) never
  /// overwrites it again.
  TextColumn get valueSource => text().withDefault(const Constant('manual'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {metricId, date},
  ];
}

/// Which checkboxes were selected that day.
class EntryOptions extends Table {
  IntColumn get entryId =>
      integer().references(Entries, #id, onDelete: KeyAction.cascade)();
  IntColumn get optionId =>
      integer().references(MetricOptions, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {entryId, optionId};
}

/// App settings key-value store.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
