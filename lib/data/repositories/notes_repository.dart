import 'package:drift/drift.dart';

import '../../core/note_links.dart';
import '../../core/note_text.dart';
import '../../core/tag_tree.dart';
import '../../features/reminders/reminder_planner.dart';
import '../db/app_database.dart';

/// A note as lists show it.
class NoteItem {
  const NoteItem({
    required this.note,
    required this.tags,
    required this.inReminders,
    this.snippet,
  });

  final Note note;
  final List<String> tags;
  final bool inReminders;

  /// Search excerpt around the first match (search results only).
  final String? snippet;

  String get id => note.id;
  String get title => NoteText.title(NoteLinks.displayText(note.body));
}

/// Everything needed to put the notes back the way they were before a merge.
class MergeUndo {
  const MergeUndo({
    required this.mergedId,
    required this.originals,
    required this.reminders,
    required this.cursor,
  });

  final String mergedId;
  final List<Note> originals;
  final List<Reminder> reminders;
  final ReminderCursor cursor;
}

/// All note, tag, version and reminder-list writes (spec §2–§6). Every body
/// write also refreshes the derived tags and the full-text index in the
/// same transaction.
class NotesRepository {
  NotesRepository(this.db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final DateTime Function() _clock;

  int get _now => _clock().millisecondsSinceEpoch;

  // ---------------------------------------------------------------- reads

  /// Notes for the list screen. [status] 'inbox' | 'archived'; [query] is
  /// free text (`#tag` words in it filter by tag); [tag] is the chip filter.
  Stream<List<NoteItem>> watchNotes({
    String status = 'inbox',
    String query = '',
    String? tag,
  }) {
    final q = _buildQuery(
      statuses: [status],
      query: query,
      tags: [?tag, ...NoteText.queryTags(query)],
      includePrivate: true,
    );
    return db
        .customSelect(
          q.sql,
          variables: q.vars,
          readsFrom: {db.notes, db.noteTags, db.reminders},
        )
        .watch()
        .map((rows) => rows.map((r) => _item(r, query)).toList());
  }

  /// One-shot variant used by the MCP tools.
  Future<List<NoteItem>> search({
    String query = '',
    String? tag,
    DateTime? since,
    bool includeArchived = false,
    bool includePrivate = false,
    int limit = 30,
    int offset = 0,
  }) async {
    final q = _buildQuery(
      statuses: includeArchived ? ['inbox', 'archived'] : ['inbox'],
      query: query,
      tags: [?tag, ...NoteText.queryTags(query)],
      includePrivate: includePrivate,
      since: since,
      limit: limit,
      offset: offset,
    );
    final rows = await db.customSelect(q.sql, variables: q.vars).get();
    return rows.map((r) => _item(r, query)).toList();
  }

  ({String sql, List<Variable> vars}) _buildQuery({
    required List<String> statuses,
    required String query,
    required List<String> tags,
    required bool includePrivate,
    DateTime? since,
    int? limit,
    int offset = 0,
  }) {
    final fts = NoteText.ftsQuery(query);
    final vars = <Variable>[];
    final where = <String>[
      'n.status IN (${statuses.map((_) => '?').join(', ')})',
    ];
    vars.addAll(statuses.map(Variable.withString));
    if (!includePrivate) where.add('n.is_private = 0');
    if (since != null) {
      where.add('n.updated_at >= ?');
      vars.add(Variable.withInt(since.millisecondsSinceEpoch));
    }
    // A tag also matches its sub-tags: #question finds #question-llm.
    for (final t in tags) {
      final tag = NoteText.lowerTr(t);
      final like = tag
          .replaceAll(r'\', r'\\')
          .replaceAll('%', r'\%')
          .replaceAll('_', r'\_');
      where.add(
        'EXISTS (SELECT 1 FROM note_tags t WHERE t.note_id = n.id '
        "AND (t.tag = ? OR t.tag LIKE ? ESCAPE '\\'))",
      );
      vars
        ..add(Variable.withString(tag))
        ..add(Variable.withString('$like${TagTree.separator}%'));
    }
    final from = fts == null
        ? 'notes n'
        : 'notes_fts f JOIN notes n ON n.id = f.note_id';
    if (fts != null) {
      where.insert(0, 'notes_fts MATCH ?');
      vars.insert(0, Variable.withString(fts));
    }
    final order = fts == null ? 'n.updated_at DESC' : 'bm25(notes_fts)';
    final page = limit == null ? '' : ' LIMIT $limit OFFSET $offset';
    return (
      sql:
          'SELECT n.*, '
          "(SELECT group_concat(tag, ' ') FROM note_tags t "
          'WHERE t.note_id = n.id) AS tag_list, '
          'EXISTS (SELECT 1 FROM reminders r WHERE r.note_id = n.id) '
          'AS in_reminders '
          'FROM $from WHERE ${where.join(' AND ')} ORDER BY $order$page',
      vars: vars,
    );
  }

  NoteItem _item(QueryRow row, String query) {
    final note = db.notes.map(row.data);
    final tagList = row.readNullable<String>('tag_list');
    return NoteItem(
      note: note,
      tags: tagList == null || tagList.isEmpty ? const [] : tagList.split(' '),
      inReminders: row.read<bool>('in_reminders'),
      snippet: NoteText.terms(query).isEmpty
          ? null
          : NoteText.snippet(NoteLinks.displayText(note.body), query),
    );
  }

  Future<Note?> getNote(String id) =>
      (db.select(db.notes)..where((n) => n.id.equals(id))).getSingleOrNull();

  Stream<Note?> watchNote(String id) =>
      (db.select(db.notes)..where((n) => n.id.equals(id))).watchSingleOrNull();

  Future<List<String>> tagsOf(String id) async => [
    for (final t in await (db.select(
      db.noteTags,
    )..where((t) => t.noteId.equals(id))).get())
      t.tag,
  ];

  /// (note, tag) pairs for the notes in [status] — the filter chips build
  /// the tag tree from these (TagTree.children).
  Stream<List<({String noteId, String tag})>> watchTagRows({
    String status = 'inbox',
  }) => db
      .customSelect(
        'SELECT t.note_id, t.tag FROM note_tags t '
        'JOIN notes n ON n.id = t.note_id WHERE n.status = ?',
        variables: [Variable.withString(status)],
        readsFrom: {db.notes, db.noteTags},
      )
      .watch()
      .map(
        (rows) => [
          for (final r in rows)
            (noteId: r.read<String>('note_id'), tag: r.read<String>('tag')),
        ],
      );

  /// Every tag in use (inbox and archive) with its note count, most used
  /// first — the editor's `#` suggestions.
  Stream<List<({String tag, int count})>> watchTagCounts() => db
      .customSelect(
        'SELECT tag, COUNT(*) AS c FROM note_tags '
        'GROUP BY tag ORDER BY c DESC, tag',
        readsFrom: {db.noteTags},
      )
      .watch()
      .map(
        (rows) => [
          for (final r in rows)
            (tag: r.read<String>('tag'), count: r.read<int>('c')),
        ],
      );

  Future<({int total, int inbox})> counts() async {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS total, '
          "COALESCE(SUM(status = 'inbox'), 0) AS inbox FROM notes",
        )
        .getSingle();
    return (total: row.read<int>('total'), inbox: row.read<int>('inbox'));
  }

  // --------------------------------------------------------------- writes

  Future<String> create(
    String body, {
    String source = 'phone',
    bool isPrivate = false,
    String? id,
  }) async {
    final noteId = id ?? NoteText.uuid();
    final now = _now;
    await db.transaction(() async {
      await db
          .into(db.notes)
          .insert(
            NotesCompanion.insert(
              id: noteId,
              body: body,
              source: Value(source),
              isPrivate: Value(isPrivate),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _index(noteId, body);
    });
    return noteId;
  }

  Future<void> updateBody(String id, String body) => db.transaction(() async {
    await (db.update(db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(body: Value(body), updatedAt: Value(_now)),
    );
    await _index(id, body);
  });

  /// Adds [text] to the end of a note (MCP append_to_note).
  Future<void> append(String id, String text) async {
    final note = await getNote(id);
    if (note == null) return;
    final body = note.body.trimRight();
    await updateBody(id, body.isEmpty ? text : '$body\n\n$text');
  }

  Future<void> setPrivate(String id, bool value) =>
      (db.update(db.notes)..where((n) => n.id.equals(id))).write(
        NotesCompanion(isPrivate: Value(value), updatedAt: Value(_now)),
      );

  /// Archived notes are deleted this long after they were archived.
  static const archiveRetention = Duration(days: 45);

  /// When an archived note will be deleted (null when not archived).
  static DateTime? deletesOn(Note note) =>
      note.status != 'archived' || note.archivedAt == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(
          note.archivedAt!,
        ).add(archiveRetention);

  /// Archiving also takes the note off the reminder list (spec §6) and
  /// starts the 45-day auto-delete clock.
  Future<void> archive(String id) => db.transaction(() async {
    await (db.update(db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(
        status: const Value('archived'),
        archivedAt: Value(_now),
        updatedAt: Value(_now),
      ),
    );
    await removeFromReminders(id);
  });

  Future<void> unarchive(String id) =>
      (db.update(db.notes)..where((n) => n.id.equals(id))).write(
        NotesCompanion(
          status: const Value('inbox'),
          archivedAt: const Value(null),
          updatedAt: Value(_now),
        ),
      );

  /// Deletes archived notes older than [archiveRetention]. Run on app
  /// start, on resume and on every push wake. Returns how many went.
  Future<int> purgeArchived() async {
    final cutoff = _clock().subtract(archiveRetention).millisecondsSinceEpoch;
    final expired =
        await (db.select(db.notes)..where(
              (n) =>
                  n.status.equals('archived') &
                  n.archivedAt.isSmallerOrEqualValue(cutoff),
            ))
            .get();
    for (final note in expired) {
      await delete(note.id);
    }
    return expired.length;
  }

  /// Deletes a note for good (in-app only, after a confirmation; never
  /// reachable from the MCP tools).
  Future<void> delete(String id) => db.transaction(() async {
    await removeFromReminders(id);
    await db.customStatement('DELETE FROM notes_fts WHERE note_id = ?', [id]);
    await (db.delete(db.notes)..where((n) => n.id.equals(id))).go();
  });

  Future<void> _index(String id, String body) async {
    await (db.delete(db.noteTags)..where((t) => t.noteId.equals(id))).go();
    for (final tag in NoteText.tags(body)) {
      await db
          .into(db.noteTags)
          .insert(NoteTagsCompanion.insert(noteId: id, tag: tag));
    }
    await db.customStatement('DELETE FROM notes_fts WHERE note_id = ?', [id]);
    await db.customStatement(
      'INSERT INTO notes_fts (note_id, body) VALUES (?, ?)',
      [id, NoteText.fold(body)],
    );
  }

  // ------------------------------------------------------------- versions

  Stream<List<NoteVersion>> watchVersions(String id) =>
      (db.select(db.noteVersions)
            ..where((v) => v.noteId.equals(id))
            ..orderBy([(v) => OrderingTerm.desc(v.id)]))
          .watch();

  /// Replaces the body, keeping the current one as a version first.
  /// False when the note no longer exists.
  Future<bool> replaceBody(String id, String body, {required String reason}) =>
      db.transaction(() async {
        final note = await getNote(id);
        if (note == null) return false;
        await db
            .into(db.noteVersions)
            .insert(
              NoteVersionsCompanion.insert(
                noteId: id,
                body: note.body,
                reason: reason,
                createdAt: _now,
              ),
            );
        await updateBody(id, body);
        return true;
      });

  Future<bool> revertTo(NoteVersion version) =>
      replaceBody(version.noteId, version.body, reason: 'revert');

  // ---------------------------------------------------------------- merge

  /// Merges [ids] into one new note (spec §4): parts oldest → newest, each
  /// under a date line; originals archived with `merged_into` set; the new
  /// note takes the earliest reminder slot of the originals.
  Future<MergeUndo> merge(List<String> ids) => db.transaction(() async {
    final originals = await (db.select(
      db.notes,
    )..where((n) => n.id.isIn(ids))).get();
    originals.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final reminderRows = await db.select(db.reminders).get();
    final cursor = await loadCursor();

    final body = [
      for (final n in originals)
        '${NoteText.mergeHeader(DateTime.fromMillisecondsSinceEpoch(n.createdAt))}'
            '\n${n.body.trim()}',
    ].join('\n\n');
    final mergedId = await create(
      body,
      source: 'merge',
      isPrivate: originals.any((n) => n.isPrivate),
    );

    final mergedPositions = reminderRows
        .where((r) => ids.contains(r.noteId))
        .map((r) => r.position)
        .toList();
    if (mergedPositions.isNotEmpty) {
      await (db.delete(db.reminders)..where((r) => r.noteId.isIn(ids))).go();
      await db
          .into(db.reminders)
          .insert(
            RemindersCompanion.insert(
              noteId: mergedId,
              position: mergedPositions.reduce((a, b) => a < b ? a : b),
            ),
          );
      if (ids.contains(cursor.noteId)) {
        await saveCursor(ReminderCursor(mergedId, cursor.slot));
      }
    }

    await (db.update(db.notes)..where((n) => n.id.isIn(ids))).write(
      NotesCompanion(
        status: const Value('archived'),
        mergedInto: Value(mergedId),
        archivedAt: Value(_now),
        updatedAt: Value(_now),
      ),
    );
    return MergeUndo(
      mergedId: mergedId,
      originals: originals,
      reminders: reminderRows,
      cursor: cursor,
    );
  });

  /// Puts everything back exactly as it was before [undo]'s merge.
  Future<void> undoMerge(MergeUndo undo) => db.transaction(() async {
    await (db.delete(
      db.reminders,
    )..where((r) => r.noteId.equals(undo.mergedId))).go();
    await delete(undo.mergedId);
    for (final n in undo.originals) {
      await db.update(db.notes).replace(n);
    }
    await db.delete(db.reminders).go();
    for (final r in undo.reminders) {
      await db.into(db.reminders).insert(r);
    }
    await saveCursor(undo.cursor);
  });

  // ------------------------------------------------------------ reminders

  Stream<List<NoteItem>> watchReminders() => db
      .customSelect(
        'SELECT n.*, '
        "(SELECT group_concat(tag, ' ') FROM note_tags t "
        'WHERE t.note_id = n.id) AS tag_list, 1 AS in_reminders '
        'FROM reminders r JOIN notes n ON n.id = r.note_id '
        'ORDER BY r.position',
        readsFrom: {db.notes, db.noteTags, db.reminders},
      )
      .watch()
      .map((rows) => rows.map((r) => _item(r, '')).toList());

  Future<List<Note>> reminderNotes() async {
    final rows = await (db.select(db.reminders).join([
      innerJoin(db.notes, db.notes.id.equalsExp(db.reminders.noteId)),
    ])..orderBy([OrderingTerm.asc(db.reminders.position)])).get();
    return [for (final r in rows) r.readTable(db.notes)];
  }

  Future<void> addToReminders(String id) => db.transaction(() async {
    await _commitCursor();
    final max = await db
        .customSelect('SELECT MAX(position) AS m FROM reminders')
        .getSingle();
    await db
        .into(db.reminders)
        .insert(
          RemindersCompanion.insert(
            noteId: id,
            position: (max.readNullable<int>('m') ?? -1) + 1,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  });

  /// Takes a note off the list; when it was due next, the following item
  /// becomes next so the order carries on.
  Future<void> removeFromReminders(String id) => db.transaction(() async {
    await _commitCursor();
    final list = await reminderNotes();
    final index = list.indexWhere((n) => n.id == id);
    if (index < 0) return;
    await (db.delete(db.reminders)..where((r) => r.noteId.equals(id))).go();
    final cursor = await loadCursor();
    if (cursor.noteId == id) {
      final rest = [...list]..removeAt(index);
      await saveCursor(
        ReminderCursor(
          rest.isEmpty ? null : rest[index % rest.length].id,
          cursor.slot,
        ),
      );
    }
  });

  /// New order for the whole list (drag and drop).
  Future<void> reorderReminders(List<String> ids) => db.transaction(() async {
    await _commitCursor();
    for (var i = 0; i < ids.length; i++) {
      await (db.update(db.reminders)..where((r) => r.noteId.equals(ids[i])))
          .write(RemindersCompanion(position: Value(i)));
    }
  });

  static const cursorNoteKey = 'reminder_next_note';
  static const cursorSlotKey = 'reminder_next_slot';
  static const reminderTimesKey = 'reminder_times';
  static const defaultReminderTimes = ['07:30', '14:00', '20:00'];

  Future<ReminderCursor> loadCursor() async {
    final rows = await (db.select(
      db.appSettings,
    )..where((s) => s.key.isIn([cursorNoteKey, cursorSlotKey]))).get();
    final map = {for (final r in rows) r.key: r.value};
    return ReminderCursor(
      map[cursorNoteKey],
      int.tryParse(map[cursorSlotKey] ?? ''),
    );
  }

  Future<void> saveCursor(ReminderCursor cursor) async {
    Future<void> put(String key, String? value) async {
      if (value == null) {
        await (db.delete(db.appSettings)..where((s) => s.key.equals(key))).go();
      } else {
        await db
            .into(db.appSettings)
            .insertOnConflictUpdate(
              AppSettingsCompanion.insert(key: key, value: value),
            );
      }
    }

    await put(cursorNoteKey, cursor.noteId);
    await put(cursorSlotKey, cursor.slot?.toString());
  }

  Future<List<String>> reminderTimes() async {
    final row = await (db.select(
      db.appSettings,
    )..where((s) => s.key.equals(reminderTimesKey))).getSingleOrNull();
    final parsed = row?.value
        .split(',')
        .map((t) => t.trim())
        .where((t) => RegExp(r'^\d{2}:\d{2}$').hasMatch(t))
        .toList();
    return parsed == null || parsed.isEmpty ? defaultReminderTimes : parsed;
  }

  /// Moves the cursor past every slot that has already fired, against the
  /// list as it is now — run before any change to the list so the items
  /// already shown are counted with the order they were shown in.
  Future<ReminderCursor> _commitCursor() async {
    final list = await reminderNotes();
    final cursor = ReminderPlanner.advance(
      now: _clock(),
      times: await reminderTimes(),
      ids: [for (final n in list) n.id],
      cursor: await loadCursor(),
    );
    await saveCursor(cursor);
    return cursor;
  }

  /// Public form of [_commitCursor] for the notification scheduler.
  Future<ReminderCursor> commitCursor() => _commitCursor();
}
