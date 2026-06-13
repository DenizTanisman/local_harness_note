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

  /// 'int' | 'text' | 'int_text' | 'checkbox' | 'composite' | 'money'
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

// ---------------------------------------------------------------- CR-3 Health

/// Health profile singleton (id always 1) — spec CR-3 §13.
class HealthProfile extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get birthDate => text().nullable()(); // 'YYYY-MM-DD'
  TextColumn get sex => text().nullable()(); // 'M' | 'F'
  RealColumn get heightCm => real().nullable()();

  /// 'sedentary' | 'light' | 'moderate' | 'active' | 'very'
  TextColumn get activityLevel => text().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Repeating body measurements; one row per day (CR-3 §13).
class BodyLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get bodyFatPct => real().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {date},
  ];
}

/// Fetched daily sensor summary (CR-3 §13). Empty until a HealthSource is
/// wired (P4); the UI reads it as placeholders.
class HealthSamples extends Table {
  TextColumn get date => text()();

  /// 'rhr'|'hr_day'|'sleep_min'|'sleep_score'|'steps'|'vo2max'|'active_kcal'
  TextColumn get kind => text()();
  RealColumn get value => real().nullable()();
  TextColumn get valueText => text().nullable()(); // e.g. sleep stages JSON
  TextColumn get source => text()(); // 'health_connect'|'huawei'|'manual'
  IntColumn get fetchedAt => integer()();

  @override
  Set<Column> get primaryKey => {date, kind};
}

/// Last successful pull per source (CR-3 §13).
class SyncState extends Table {
  TextColumn get source => text()();
  IntColumn get lastSync => integer().nullable()();

  @override
  Set<Column> get primaryKey => {source};
}

// ----------------------------------------------------------------- CR-3 Sport

/// Autocomplete dictionary of exercise names (CR-3 §12). INSERT OR IGNORE.
class SavedExerciseTitles extends Table {
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {name};
}

/// Autocomplete dictionary of food types (CR-3 §12). Seeded builtins +
/// user additions; INSERT OR IGNORE.
class SavedFoodTypes extends Table {
  TextColumn get name => text()();
  BoolColumn get isBuiltin => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {name};
}

/// Workout programs (CR-3 §13).
class Programs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get createdAt => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Exercise blocks within a program (CR-3 §13). [sets]/[duration]: at least
/// one non-null, enforced by the app layer. Same [supersetGroup] = a
/// superset performed [supersetRounds] times together.
class ProgramExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get programId =>
      integer().references(Programs, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get sets => text().nullable()();
  TextColumn get duration => text().nullable()();
  BoolColumn get restAfter => boolean().withDefault(const Constant(false))();
  IntColumn get supersetGroup => integer().nullable()();
  IntColumn get supersetRounds => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Per-meal calorie intake entries (CR-3 §13).
class CalorieEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  TextColumn get meal => text().nullable()(); // 'breakfast'|'lunch'|'dinner'
  RealColumn get kcal =>
      real().customConstraint('NOT NULL CHECK (kcal >= 0)')();
  TextColumn get type => text()(); // saved_food_types.name
  IntColumn get createdAt => integer()();
}

/// Derived daily calorie total + FROZEN target/color (CR-3 §11). Written
/// on entry, never recomputed on read.
class CalorieDay extends Table {
  TextColumn get date => text()();
  RealColumn get intake => real().withDefault(const Constant(0))();
  RealColumn get targetSnapshot => real().nullable()();
  TextColumn get color => text().nullable()(); // 'green'|'yellow'|'red'|NULL

  @override
  Set<Column> get primaryKey => {date};
}

/// Daily program activity for the Programs sparkline (CR-3 §11).
class ProgramLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  IntColumn get programId =>
      integer().references(Programs, #id, onDelete: KeyAction.cascade)();
  RealColumn get volume => real().withDefault(const Constant(0))();
}
