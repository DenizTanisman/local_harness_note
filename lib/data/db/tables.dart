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

  /// When the note went to the archive; archived notes are deleted
  /// [NotesRepository.archiveRetention] after this.
  IntColumn get archivedAt => integer().nullable()();
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

/// An HTML tutorial with its recall pack (lib/core/lesson_format.dart).
class Lessons extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get html => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  /// Last time it was opened; the Dersler list puts recent ones first.
  IntColumn get openedAt => integer().nullable()();

  /// Reading position (CSS px), restored when the lesson reopens.
  IntColumn get scrollY => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One recall run of one lesson section on one day. The questions are
/// fixed when it starts; it is evaluated (results, wrong-card markers) once
/// every one of them is answered — or when its day is over.
class RecallSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get lessonId =>
      text().references(Lessons, #id, onDelete: KeyAction.cascade)();
  TextColumn get section => text()();

  /// Local calendar day, as days since 1970-01-01 (RecallDay).
  IntColumn get day => integer()();

  /// Question ids in asking order, comma separated.
  TextColumn get questionIds => text()();
  IntColumn get createdAt => integer()();
  IntColumn get finishedAt => integer().nullable()();
}

class RecallAnswers extends Table {
  IntColumn get sessionId =>
      integer().references(RecallSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get questionId => text()();

  /// Index of the chosen option.
  IntColumn get chosen => integer()();
  BoolColumn get correct => boolean()();
  IntColumn get answeredAt => integer()();

  @override
  Set<Column> get primaryKey => {sessionId, questionId};
}
