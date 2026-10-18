import 'lesson_format.dart';

/// Local calendar days as integers (days since 1970-01-01), so "the next
/// day" and "a week later" are plain additions.
class RecallDay {
  RecallDay._();

  static int of(DateTime t) =>
      DateTime.utc(t.year, t.month, t.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  /// Local midnight of [day].
  static DateTime start(int day) {
    final u = DateTime.fromMillisecondsSinceEpoch(
      day * Duration.millisecondsPerDay,
      isUtc: true,
    );
    return DateTime(u.year, u.month, u.day);
  }
}

class RecallSessionData {
  const RecallSessionData({
    required this.id,
    required this.section,
    required this.day,
    required this.questionIds,
    required this.finished,
    required this.createdAt,
  });

  final int id;
  final String section;
  final int day;
  final List<String> questionIds;
  final bool finished;

  /// Epoch ms; the first run's time of day is when stage reminders ring.
  final int createdAt;

  /// Results count once every question is answered or the day is over
  /// ("o günkü tüm sorular bitince").
  bool evaluatedOn(int today) => finished || day < today;
}

class RecallAnswerData {
  const RecallAnswerData({
    required this.sessionId,
    required this.questionId,
    required this.chosen,
    required this.correct,
    required this.answeredAt,
  });

  final int sessionId;
  final String questionId;
  final int chosen;
  final bool correct;
  final int answeredAt;
}

/// What a section's Recall button shows.
class SectionStatus {
  const SectionStatus({
    required this.section,
    required this.due,
    required this.resume,
    required this.wrong,
    required this.started,
    required this.review,
    this.nextDay,
    this.nextStage,
  });

  final String section;

  /// Questions waiting today (including the rest of an unfinished run).
  final int due;

  /// Part of [due] that continues today's unfinished run.
  final int resume;

  /// Questions whose last evaluated answer is wrong (marked cards).
  final int wrong;
  final bool started;

  /// The genel tekrar day has come (5 days after the start).
  final bool review;

  /// When a stage with unanswered questions unlocks next, if any.
  final int? nextDay;
  final int? nextStage;
}

/// Pure active-recall rules (docs/lesson-format.md):
/// - a section starts the first day its Recall runs; stage 1 is asked that
///   day, stage 2 one day later, stage 3 three days later, and five days
///   later every question once more (genel tekrar);
/// - a question is due once its stage is unlocked and it was never
///   answered, or its last answer was wrong on an earlier day, or — from
///   the review day on — it was last answered before that day;
/// - a run is evaluated when all its questions are answered or its day is
///   over; only evaluated wrong answers mark cards, and a later right
///   answer clears the mark.
class RecallPlanner {
  RecallPlanner({
    required this.pack,
    required List<RecallSessionData> sessions,
    required List<RecallAnswerData> answers,
    required this.today,
  }) : _sessions = {for (final s in sessions) s.id: s},
       _answers = [...answers]
         ..sort((a, b) => a.answeredAt.compareTo(b.answeredAt));

  final LessonPack pack;
  final int today;
  final Map<int, RecallSessionData> _sessions;
  final List<RecallAnswerData> _answers;

  RecallSessionData? _first(String section) {
    RecallSessionData? first;
    for (final s in _sessions.values) {
      if (s.section == section &&
          (first == null || s.createdAt < first.createdAt)) {
        first = s;
      }
    }
    return first;
  }

  int? startDay(String section) => _first(section)?.day;

  /// When the section's first run began (epoch ms).
  int? startedAt(String section) => _first(section)?.createdAt;

  int? _reviewDay(String section) {
    final start = startDay(section);
    return start == null ? null : start + recallReviewOffset;
  }

  bool isReview(String section) {
    final day = _reviewDay(section);
    return day != null && today >= day;
  }

  /// Not yet answered on or after the review day.
  bool _beforeReview(RecallAnswerData? last, int reviewDay) =>
      last == null || (_sessions[last.sessionId]?.day ?? 0) < reviewDay;

  bool _unlocked(RecallQuestion q, int? start) =>
      (start ?? today) + recallStageOffsets[q.stage]! <= today;

  /// Latest answer per question; [evaluatedOnly] skips runs still open.
  Map<String, RecallAnswerData> _latest({required bool evaluatedOnly}) {
    final out = <String, RecallAnswerData>{};
    for (final a in _answers) {
      final s = _sessions[a.sessionId];
      if (s == null) continue;
      if (evaluatedOnly && !s.evaluatedOn(today)) continue;
      out[a.questionId] = a;
    }
    return out;
  }

  /// Today's unfinished run of [section], if any.
  RecallSessionData? openSession(String section) {
    for (final s in _sessions.values) {
      if (s.section == section && s.day == today && !s.finished) return s;
    }
    return null;
  }

  Set<String> _answeredIn(int sessionId) => {
    for (final a in _answers)
      if (a.sessionId == sessionId) a.questionId,
  };

  /// Questions of today's open run not answered yet.
  List<String> remaining(RecallSessionData session) {
    final done = _answeredIn(session.id);
    return [
      for (final id in session.questionIds)
        if (!done.contains(id)) id,
    ];
  }

  /// Questions a new run of [section] would ask today.
  List<RecallQuestion> due(String section) {
    final start = startDay(section);
    final latest = _latest(evaluatedOnly: false);
    final review = isReview(section) ? _reviewDay(section) : null;
    return [
      for (final q in pack.ofSection(section))
        if (_unlocked(q, start) &&
            (_isDue(latest[q.id]) ||
                (review != null && _beforeReview(latest[q.id], review))))
          q,
    ];
  }

  bool _isDue(RecallAnswerData? last) {
    if (last == null) return true;
    if (last.correct) return false;
    final s = _sessions[last.sessionId];
    return s != null && s.day < today;
  }

  /// Every unlocked question — the "hepsini yeniden çöz" run.
  List<RecallQuestion> practice(String section) {
    final start = startDay(section);
    return [
      for (final q in pack.ofSection(section))
        if (_unlocked(q, start)) q,
    ];
  }

  /// Questions to mark as wrong, in tutorial order (section, then pack).
  List<RecallQuestion> wrong({String? section}) {
    final latest = _latest(evaluatedOnly: true);
    return [
      for (final s in pack.sections)
        if (section == null || s.id == section)
          for (final q in pack.ofSection(s.id))
            if (latest[q.id] case final a? when !a.correct) q,
    ];
  }

  /// Card ids to mark, without repeats, in tutorial order.
  List<String> markedAnchors() {
    final seen = <String>{};
    return [
      for (final q in wrong())
        if (seen.add(q.anchor)) q.anchor,
    ];
  }

  SectionStatus status(String section) {
    final open = openSession(section);
    final resume = open == null ? 0 : remaining(open).length;
    final start = startDay(section);
    final latest = _latest(evaluatedOnly: false);
    int? nextDay;
    int? nextStage;
    if (start != null) {
      for (final q in pack.ofSection(section)) {
        final day = start + recallStageOffsets[q.stage]!;
        if (day > today &&
            latest[q.id] == null &&
            (nextDay == null || day < nextDay)) {
          nextDay = day;
          nextStage = q.stage;
        }
      }
      final review = start + recallReviewOffset;
      if (review > today && (nextDay == null || review < nextDay)) {
        nextDay = review;
        nextStage = recallReviewStage;
      }
    }
    return SectionStatus(
      section: section,
      due: open != null ? resume : due(section).length,
      resume: resume,
      wrong: wrong(section: section).length,
      started: start != null,
      review: isReview(section),
      nextDay: nextDay,
      nextStage: nextStage,
    );
  }

  /// The 1-, 3- and 5-day reviews of every started section still ahead
  /// (today included) with questions waiting: feeds the stage reminders.
  List<({String section, int day, int stage, int count})> upcoming() {
    final latest = _latest(evaluatedOnly: false);
    final out = <({String section, int day, int stage, int count})>[];
    for (final s in pack.sections) {
      final start = startDay(s.id);
      if (start == null) continue;
      final questions = pack.ofSection(s.id);
      for (final stage in const [2, 3]) {
        final day = start + recallStageOffsets[stage]!;
        if (day < today) continue;
        final count = questions
            .where((q) => q.stage == stage && latest[q.id] == null)
            .length;
        if (count > 0) {
          out.add((section: s.id, day: day, stage: stage, count: count));
        }
      }
      final review = start + recallReviewOffset;
      final left = questions
          .where((q) => _beforeReview(latest[q.id], review))
          .length;
      if (review >= today && left > 0) {
        out.add((
          section: s.id,
          day: review,
          stage: recallReviewStage,
          count: left,
        ));
      }
    }
    return out;
  }
}
