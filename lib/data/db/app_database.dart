import 'package:drift/drift.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Notes, NoteTags, NoteVersions, Reminders, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// v1: daily check-in (metric tree). v2: second brain notes
  /// (docs/second-brain-spec.md) — the check-in tables are dropped.
  @override
  int get schemaVersion => 2;

  /// Settings that only the check-in used; removed by the v2 upgrade.
  static const obsoleteSettings = [
    'morning_time',
    'evening_time',
    'quotes_enabled',
    'quote_lang',
    'quotes_custom_tr',
    'quotes_custom_en',
    'autofill_instagram',
  ];

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createSearchIndex();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        for (final table in [
          'entry_options',
          'entries',
          'metric_options',
          'metrics',
        ]) {
          await customStatement('DROP TABLE IF EXISTS $table');
        }
        await m.createTable(notes);
        await m.createTable(noteTags);
        await m.createTable(noteVersions);
        await m.createTable(reminders);
        await _createSearchIndex();
        await (delete(
          appSettings,
        )..where((s) => s.key.isIn(obsoleteSettings))).go();
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Full-text index over the folded body (NoteText.fold), maintained by
  /// NotesRepository in the same transaction as every body write.
  Future<void> _createSearchIndex() async {
    await customStatement(
      'CREATE VIRTUAL TABLE IF NOT EXISTS notes_fts USING fts5('
      'note_id UNINDEXED, body, '
      "tokenize = 'unicode61 remove_diacritics 2')",
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_notes_updated ON notes(updated_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_note_tags_tag ON note_tags(tag)',
    );
  }
}
