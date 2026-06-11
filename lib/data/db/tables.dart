import 'package:drift/drift.dart';

/// Metric tree: every card is a row — groups and leaves alike (ADR-2).
class Metrics extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get parentId => integer()
      .nullable()
      .references(Metrics, #id, onDelete: KeyAction.cascade)();
  TextColumn get key => text().unique()();
  TextColumn get title => text()();

  /// 'int' | 'text' | 'int_text' | 'checkbox' | 'composite' | 'money'
  TextColumn get inputType => text()();
  BoolColumn get isStarred => boolean().withDefault(const Constant(false))();
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

/// Daily values: ONE row per metric × day (Money exempt — uses transactions).
class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get metricId =>
      integer().references(Metrics, #id, onDelete: KeyAction.cascade)();

  /// 'YYYY-MM-DD' local time.
  TextColumn get date => text()();
  RealColumn get numValue => real().nullable()();
  TextColumn get textValue => text().nullable()();
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

/// Money subsystem: N transactions per day (ADR-4).
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();

  /// 'income' | 'outcome'
  TextColumn get direction => text()();
  RealColumn get amount =>
      real().customConstraint('NOT NULL CHECK (amount >= 0)')();
  TextColumn get category => text()();

  /// NULL → plain category; 'home' → shown as 'Bill (home)'.
  TextColumn get subtype => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}

/// Category dictionary: dropdown source + essential / heatmap flags.
class MoneyCategories extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 'income' | 'outcome'
  TextColumn get direction => text()();
  TextColumn get name => text()();

  /// 1 → subtracted in the red/green budget formula.
  BoolColumn get isEssential => boolean().withDefault(const Constant(false))();

  /// 1 → included in the Money heatmap daily sum (food + entertainment).
  BoolColumn get countsInHeatmap =>
      boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {direction, name},
      ];
}

/// Expense reminder queue (local notifications).
class ExpenseReminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId =>
      integer().references(Transactions, #id, onDelete: KeyAction.cascade)();
  TextColumn get remindDate => text()();
  BoolColumn get fired => boolean().withDefault(const Constant(false))();
}

/// App settings key-value store.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
