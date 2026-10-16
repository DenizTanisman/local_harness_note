import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// Typed access over the app_settings key-value table (spec 6.6).
class SettingsRepository {
  SettingsRepository(this.db);

  final AppDatabase db;

  Stream<Map<String, String>> watchAll() => db
      .select(db.appSettings)
      .watch()
      .map((rows) => {for (final r in rows) r.key: r.value});

  Future<Map<String, String>> loadAll() async => {
    for (final r in await db.select(db.appSettings).get()) r.key: r.value,
  };

  Future<void> remove(String key) =>
      (db.delete(db.appSettings)..where((s) => s.key.equals(key))).go();

  Future<void> set(String key, String value) => db
      .into(db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion(key: Value(key), value: Value(value)),
      );
}
