import 'package:drift/drift.dart';

/// One note (spec §2). Plain text; the first line doubles as its title.
class Notes extends Table {
  /// uuid v4 — also used for notes Claude creates through the relay.
  TextColumn get id => text()();
  TextColumn get body => text()();

  /// 'inbox' | 'archived'
  TextColumn get status => text().withDefault(const Constant('inbox'))();

  /// Private notes never leave the device: the MCP tools skip them.
  BoolColumn get isPrivate => boolean().withDefault(const Constant(false))();

  /// 'phone' | 'claude' | 'share' | 'merge'
  TextColumn get source => text().withDefault(const Constant('phone'))();

  /// Set on notes archived by a merge: the id of the merged note.
  TextColumn get mergedInto => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// `#tags` derived from the body on every save.
class NoteTags extends Table {
  TextColumn get noteId =>
      text().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get tag => text()();

  @override
  Set<Column> get primaryKey => {noteId, tag};
}

/// Earlier bodies of a note, kept whenever Gemma or a revert replaces it.
class NoteVersions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get noteId =>
      text().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get body => text()();

  /// 'gemma' | 'revert'
  TextColumn get reason => text()();
  IntColumn get createdAt => integer()();
}

/// The ordered reminder list (spec §6). Every item is a note.
class Reminders extends Table {
  TextColumn get noteId =>
      text().references(Notes, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {noteId};
}

/// App settings key-value store.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
