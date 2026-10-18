import 'package:drift/drift.dart';

import '../../core/lesson_format.dart';
import '../../core/note_text.dart';
import '../../core/recall_planner.dart';
import '../db/app_database.dart';

/// A lesson as the Dersler list shows it.
class LessonSummary {
  const LessonSummary({
    required this.lesson,
    required this.sections,
    required this.questions,
    required this.dueToday,
    required this.wrong,
    required this.started,
  });

  final Lesson lesson;
  final int sections;
  final int questions;
  final int dueToday;
  final int wrong;

  /// Sections whose recall has begun.
  final int started;
}

/// One finished (or abandoned) run, for results and history.
class RecallResult {
  const RecallResult({required this.session, required this.items});

  final RecallSession session;

  /// Asked questions in order, with the chosen option (null: skipped).
  final List<({RecallQuestion question, int? chosen})> items;

  int get answered => items.where((i) => i.chosen != null).length;
  int get correct => items.where((i) => i.chosen == i.question.answer).length;
  List<({RecallQuestion question, int? chosen})> get wrong => [
    for (final i in items)
      if (i.chosen != null && i.chosen != i.question.answer) i,
  ];
}

/// Lessons and their recall runs. The HTML is stored whole in the
/// encrypted database; the recall pack is parsed from it on demand.
class LessonsRepository {
  LessonsRepository(this.db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final DateTime Function() _clock;
  final _packs = <String, (int, LessonPack)>{};

  int get _now => _clock().millisecondsSinceEpoch;
  int get today => RecallDay.of(_clock());

  LessonPack pack(Lesson lesson) {
    final cached = _packs[lesson.id];
    if (cached != null && cached.$1 == lesson.updatedAt) return cached.$2;
    final parsed = LessonFormat.parse(lesson.html);
    _packs[lesson.id] = (lesson.updatedAt, parsed);
    return parsed;
  }

  // ---------------------------------------------------------------- lessons

  /// Adds [html] as a lesson; a lesson with the same title is updated in
  /// place so its progress stays. Returns the lesson and whether it
  /// replaced one. Throws [LessonFormatException] for files without a
  /// recall pack.
  Future<(Lesson, bool)> import(String html) async {
    final parsed = LessonFormat.parse(html);
    final now = _now;
    return db.transaction(() async {
      final existing = await (db.select(
        db.lessons,
      )..where((l) => l.title.equals(parsed.title))).getSingleOrNull();
      if (existing != null) {
        await (db.update(db.lessons)..where((l) => l.id.equals(existing.id)))
            .write(LessonsCompanion(html: Value(html), updatedAt: Value(now)));
        return (existing.copyWith(html: html, updatedAt: now), true);
      }
      final lesson = Lesson(
        id: NoteText.uuid(),
        title: parsed.title,
        html: html,
        createdAt: now,
        updatedAt: now,
        openedAt: now,
      );
      await db.into(db.lessons).insert(lesson);
      return (lesson, false);
    });
  }

  Future<Lesson?> get(String id) =>
      (db.select(db.lessons)..where((l) => l.id.equals(id))).getSingleOrNull();

  Future<void> markOpened(String id) =>
      (db.update(db.lessons)..where((l) => l.id.equals(id))).write(
        LessonsCompanion(openedAt: Value(_now)),
      );

  Future<void> saveScroll(String id, int y) => (db.update(
    db.lessons,
  )..where((l) => l.id.equals(id))).write(LessonsCompanion(scrollY: Value(y)));

  /// Deletes the lesson with all its recall history.
  Future<void> delete(String id) async {
    _packs.remove(id);
    await (db.delete(db.lessons)..where((l) => l.id.equals(id))).go();
  }

  /// The Dersler list, refreshed whenever lessons or recall answers change
  /// (due counts move with every answer).
  Stream<List<LessonSummary>> watchLessons() async* {
    yield await _summaries();
    await for (final _ in db.tableUpdates(
      TableUpdateQuery.onAllTables([
        db.lessons,
        db.recallSessions,
        db.recallAnswers,
      ]),
    )) {
      yield await _summaries();
    }
  }

  Future<List<LessonSummary>> _summaries() async {
    final lessons =
        await (db.select(db.lessons)..orderBy([
              (l) => OrderingTerm.desc(coalesce([l.openedAt, l.createdAt])),
            ]))
            .get();
    final out = <LessonSummary>[];
    for (final l in lessons) {
      final LessonPack p;
      try {
        p = pack(l);
      } on LessonFormatException {
        continue;
      }
      final planner = await plannerFor(l);
      final statuses = [for (final s in p.sections) planner.status(s.id)];
      out.add(
        LessonSummary(
          lesson: l,
          sections: p.sections.length,
          questions: p.questions.length,
          dueToday: statuses
              .where((s) => s.started)
              .fold(0, (n, s) => n + s.due),
          wrong: planner.markedAnchors().length,
          started: statuses.where((s) => s.started).length,
        ),
      );
    }
    return out;
  }

  // ---------------------------------------------------------------- recall

  Future<RecallPlanner> plannerFor(Lesson lesson) async {
    final sessions = await (db.select(
      db.recallSessions,
    )..where((s) => s.lessonId.equals(lesson.id))).get();
    final ids = [for (final s in sessions) s.id];
    final answers = ids.isEmpty
        ? <RecallAnswer>[]
        : await (db.select(
            db.recallAnswers,
          )..where((a) => a.sessionId.isIn(ids))).get();
    return RecallPlanner(
      pack: pack(lesson),
      today: today,
      sessions: [
        for (final s in sessions)
          RecallSessionData(
            id: s.id,
            section: s.section,
            day: s.day,
            questionIds: _split(s.questionIds),
            finished: s.finishedAt != null,
            createdAt: s.createdAt,
          ),
      ],
      answers: [
        for (final a in answers)
          RecallAnswerData(
            sessionId: a.sessionId,
            questionId: a.questionId,
            chosen: a.chosen,
            correct: a.correct,
            answeredAt: a.answeredAt,
          ),
      ],
    );
  }

  /// Changes to recall runs and answers.
  Stream<void> watchRecall() => db.tableUpdates(
    TableUpdateQuery.onAllTables([db.recallSessions, db.recallAnswers]),
  );

  static List<String> _split(String ids) =>
      ids.isEmpty ? const [] : ids.split(',');

  /// Today's run of [section]: the unfinished one, else a new one with the
  /// due questions (all unlocked ones when [practice]). Null when nothing
  /// is due. Returns the session and the questions still to answer.
  Future<(RecallSession, List<RecallQuestion>)?> startOrResume(
    Lesson lesson,
    String section, {
    bool practice = false,
  }) async {
    final planner = await plannerFor(lesson);
    final p = pack(lesson);
    final byId = {for (final q in p.questions) q.id: q};
    final open = planner.openSession(section);
    if (open != null && !practice) {
      final session = await _session(open.id);
      return (
        session,
        [
          for (final id in planner.remaining(open))
            if (byId[id] != null) byId[id]!,
        ],
      );
    }
    final questions = practice
        ? planner.practice(section)
        : planner.due(section);
    if (questions.isEmpty) return null;
    if (open != null) await finish(open.id); // practice replaces it
    final id = await db
        .into(db.recallSessions)
        .insert(
          RecallSessionsCompanion.insert(
            lessonId: lesson.id,
            section: section,
            day: today,
            questionIds: questions.map((q) => q.id).join(','),
            createdAt: _now,
          ),
        );
    return (await _session(id), questions);
  }

  Future<RecallSession> _session(int id) =>
      (db.select(db.recallSessions)..where((s) => s.id.equals(id))).getSingle();

  Future<void> answer(int sessionId, RecallQuestion question, int chosen) => db
      .into(db.recallAnswers)
      .insertOnConflictUpdate(
        RecallAnswersCompanion.insert(
          sessionId: sessionId,
          questionId: question.id,
          chosen: chosen,
          correct: chosen == question.answer,
          answeredAt: _now,
        ),
      );

  Future<void> finish(int sessionId) =>
      (db.update(db.recallSessions)
            ..where((s) => s.id.equals(sessionId) & s.finishedAt.isNull()))
          .write(RecallSessionsCompanion(finishedAt: Value(_now)));

  Future<RecallResult> result(Lesson lesson, int sessionId) async {
    final session = await _session(sessionId);
    final answers = await (db.select(
      db.recallAnswers,
    )..where((a) => a.sessionId.equals(sessionId))).get();
    final chosen = {for (final a in answers) a.questionId: a.chosen};
    final byId = {for (final q in pack(lesson).questions) q.id: q};
    return RecallResult(
      session: session,
      items: [
        for (final id in _split(session.questionIds))
          if (byId[id] != null) (question: byId[id]!, chosen: chosen[id]),
      ],
    );
  }

  /// Every run of a lesson with at least one answer, newest first.
  Future<List<RecallResult>> history(Lesson lesson) async {
    final sessions =
        await (db.select(db.recallSessions)
              ..where((s) => s.lessonId.equals(lesson.id))
              ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
            .get();
    final out = <RecallResult>[];
    for (final s in sessions) {
      final r = await result(lesson, s.id);
      if (r.answered > 0) out.add(r);
    }
    return out;
  }

  /// Lessons with their planners — for the stage reminders.
  Future<List<(Lesson, RecallPlanner)>> allPlanners() async {
    final out = <(Lesson, RecallPlanner)>[];
    for (final l in await db.select(db.lessons).get()) {
      try {
        out.add((l, await plannerFor(l)));
      } on LessonFormatException {
        continue;
      }
    }
    return out;
  }
}
