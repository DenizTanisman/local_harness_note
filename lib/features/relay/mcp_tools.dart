import '../../core/note_text.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/notes_repository.dart';

/// A tool call the phone could not carry out (unknown note, bad args …).
class ToolError implements Exception {
  const ToolError(this.message);
  final String message;

  @override
  String toString() => message;
}

/// The phone side of the MCP tools (spec §8.1). Private notes are invisible
/// to every tool; there is no delete tool.
class McpTools {
  McpTools(this.db) : repo = NotesRepository(db);

  final AppDatabase db;
  final NotesRepository repo;

  static const writeTools = {
    'create_note',
    'append_to_note',
    'archive_note',
    'add_to_reminders',
  };

  static const _doneKey = 'relay_done';
  static const _doneKept = 300;

  /// Runs [tool]. Write calls are idempotent per [reqId]: a request that
  /// arrives twice (late push + queue) is applied once.
  Future<Map<String, Object?>> execute(
    String tool,
    Map<String, Object?> args, {
    required String reqId,
  }) async {
    if (writeTools.contains(tool)) {
      final done = await _done();
      if (done.contains(reqId)) return {'ok': true, 'duplicate': true};
      final result = await _run(tool, args);
      await _markDone(done, reqId);
      return result;
    }
    return _run(tool, args);
  }

  Future<Map<String, Object?>> _run(
    String tool,
    Map<String, Object?> args,
  ) async {
    switch (tool) {
      case 'ping':
        return {'pong': true};
      case 'search_notes':
        final since = _date(args['since']);
        final hits = await repo.search(
          query: _str(args['query']) ?? '',
          tag: _str(args['tag']),
          since: since,
          includeArchived: args['include_archived'] == true,
          limit: _limit(args['limit']),
        );
        return {'results': hits.map(_summary).toList()};
      case 'list_recent':
        final days = (args['days'] as num?)?.toInt() ?? 7;
        final offset = int.tryParse('${args['cursor'] ?? 0}') ?? 0;
        final limit = _limit(args['limit']);
        final hits = await repo.search(
          tag: _str(args['tag']),
          since: DateTime.now().subtract(Duration(days: days)),
          limit: limit,
          offset: offset,
        );
        return {
          'results': hits.map(_summary).toList(),
          'next_cursor': hits.length == limit ? '${offset + limit}' : null,
        };
      case 'get_note':
        final note = await _visible(args['id']);
        return {
          'id': note.id,
          'body': note.body,
          'tags': await repo.tagsOf(note.id),
          'status': _status(note.status),
          'created': _iso(note.createdAt),
          'updated': _iso(note.updatedAt),
          'in_reminders': await _inReminders(note.id),
          'auto_delete_on': _day(NotesRepository.deletesOn(note)),
        };
      case 'create_note':
        final text = _str(args['text']);
        if (text == null || text.trim().isEmpty) {
          throw const ToolError('text boş olamaz');
        }
        final id = await repo.create(text.trim(), source: 'claude');
        return {'id': id, 'title': NoteText.title(text)};
      case 'append_to_note':
        final note = await _visible(args['id']);
        final text = _str(args['text']);
        if (text == null || text.trim().isEmpty) {
          throw const ToolError('text boş olamaz');
        }
        await repo.append(note.id, text.trim());
        return {'ok': true, 'id': note.id};
      case 'archive_note':
        final note = await _visible(args['id']);
        await repo.archive(note.id);
        return {'ok': true, 'id': note.id};
      case 'add_to_reminders':
        final note = await _visible(args['id']);
        if (note.status == 'archived') await repo.unarchive(note.id);
        await repo.addToReminders(note.id);
        return {'ok': true, 'id': note.id};
    }
    throw ToolError('Bilinmeyen araç: $tool');
  }

  Map<String, Object?> _summary(NoteItem n) => {
    'id': n.id,
    'title': n.title,
    'snippet': n.snippet ?? NoteText.snippet(n.note.body, ''),
    'tags': n.tags,
    'status': _status(n.note.status),
    'updated': _iso(n.note.updatedAt),
    if (NotesRepository.deletesOn(n.note) case final DateTime d)
      'auto_delete_on': _day(d),
  };

  Future<Note> _visible(Object? id) async {
    final note = id is String ? await repo.getNote(id) : null;
    if (note == null || note.isPrivate) {
      throw ToolError('Not bulunamadı: $id');
    }
    return note;
  }

  Future<bool> _inReminders(String id) async =>
      await (db.select(
        db.reminders,
      )..where((r) => r.noteId.equals(id))).getSingleOrNull() !=
      null;

  Future<List<String>> _done() async {
    final row = await (db.select(
      db.appSettings,
    )..where((s) => s.key.equals(_doneKey))).getSingleOrNull();
    return row == null || row.value.isEmpty ? [] : row.value.split(',');
  }

  Future<void> _markDone(List<String> done, String reqId) async {
    final next = [...done, reqId];
    final kept = next.length > _doneKept
        ? next.sublist(next.length - _doneKept)
        : next;
    await db
        .into(db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: _doneKey, value: kept.join(',')),
        );
  }

  static String? _str(Object? v) =>
      v is String && v.trim().isNotEmpty ? v : null;

  static int _limit(Object? v) => ((v as num?)?.toInt() ?? 20).clamp(1, 30);

  static DateTime? _date(Object? v) =>
      v is String ? DateTime.tryParse(v) : null;

  static String _status(String s) => s == 'archived' ? 'arşiv' : 'gelen';

  static String? _day(DateTime? d) => d?.toIso8601String().substring(0, 10);

  static String _iso(int ms) => DateTime.fromMillisecondsSinceEpoch(
    ms,
  ).toIso8601String().substring(0, 16);
}
