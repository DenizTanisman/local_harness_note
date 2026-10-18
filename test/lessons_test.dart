import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_harness_not/core/lesson_format.dart';
import 'package:local_harness_not/core/recall_planner.dart';
import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/repositories/lessons_repository.dart';

/// A lesson with two sections: s1 has stage 1/2/3 questions, s2 one.
String lessonHtml({String title = 'Deneme dersi', String extra = ''}) {
  Map<String, Object> q(String id, String section, int stage, int answer) => {
    'id': id,
    'section': section,
    'stage': stage,
    'anchor': 'k-$id',
    'q': 'Soru $id?',
    'options': ['a', 'b', 'c', 'd'],
    'answer': answer,
    'why': 'Çünkü.',
  };
  final pack = {
    'title': title,
    'sections': [
      {'id': 's1', 'title': 'Bir'},
      {'id': 's2', 'title': 'İki'},
    ],
    'questions': [
      q('a', 's1', 1, 0),
      q('b', 's1', 1, 1),
      q('c', 's1', 2, 2),
      q('d', 's1', 3, 3),
      q('e', 's2', 1, 0),
    ],
  };
  return '<!doctype html><title>Başlık</title><body>'
      '<section id="s1"><h2>Bir</h2></section>'
      '<section id="s2"><h2>İki</h2></section>$extra'
      '<script type="application/json" id="not-recall">'
      '${jsonEncode(pack)}</script></body>';
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('LessonFormat', () {
    test('reads the embedded pack', () {
      final pack = LessonFormat.parse(lessonHtml());
      expect(pack.title, 'Deneme dersi');
      expect(pack.sections.map((s) => s.id), ['s1', 's2']);
      expect(pack.ofSection('s1').map((q) => q.id), ['a', 'b', 'c', 'd']);
      expect(pack.questions.first.anchor, 'k-a');
    });

    test('a file without a pack is refused with a Turkish message', () {
      expect(
        () => LessonFormat.parse('<html><title>x</title></html>'),
        throwsA(isA<LessonFormatException>()),
      );
    });

    test('broken questions are skipped, not the whole lesson', () {
      final html = lessonHtml().replaceFirst('"answer":0', '"answer":9');
      final pack = LessonFormat.parse(html);
      expect(pack.questions.map((q) => q.id), isNot(contains('a')));
      expect(pack.questions, hasLength(4));
    });
  });

  group('LessonsRepository + RecallPlanner', () {
    late AppDatabase db;
    late LessonsRepository repo;
    var now = DateTime(2026, 10, 18, 10);

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      now = DateTime(2026, 10, 18, 10);
      repo = LessonsRepository(db, clock: () => now);
    });
    tearDown(() => db.close());

    Future<Lesson> lesson() async => (await repo.import(lessonHtml())).$1;

    Future<RecallPlanner> planner(Lesson l) => repo.plannerFor(l);

    Future<void> answerAll(
      RecallSession session,
      List<RecallQuestion> qs,
      Map<String, int> picks,
    ) async {
      for (final q in qs) {
        await repo.answer(session.id, q, picks[q.id] ?? q.answer);
      }
      await repo.finish(session.id);
    }

    test('re-importing the same title updates it and keeps progress', () async {
      final l = await lesson();
      final run = (await repo.startOrResume(l, 's1'))!;
      await answerAll(run.$1, run.$2, {});
      final (again, replaced) = await repo.import(lessonHtml(extra: '<p>yeni'));
      expect(replaced, isTrue);
      expect(again.id, l.id);
      expect((await repo.get(l.id))!.html, contains('yeni'));
      expect(await repo.history(again), hasLength(1));
    });

    test(
      'day 0 asks stage 1 only, then stage 2 next day, 3 a week later',
      () async {
        final l = await lesson();
        final run = (await repo.startOrResume(l, 's1'))!;
        expect(run.$2.map((q) => q.id), ['a', 'b']);
        await answerAll(run.$1, run.$2, {});
        expect(await repo.startOrResume(l, 's1'), isNull);
        expect((await planner(l)).status('s1').nextStage, 2);

        now = now.add(const Duration(days: 1));
        final day1 = (await repo.startOrResume(l, 's1'))!;
        expect(day1.$2.map((q) => q.id), ['c']);
        await answerAll(day1.$1, day1.$2, {});

        now = now.add(const Duration(days: 5)); // day 6: nothing yet
        expect(await repo.startOrResume(l, 's1'), isNull);
        now = now.add(const Duration(days: 1)); // day 7
        final day7 = (await repo.startOrResume(l, 's1'))!;
        expect(day7.$2.map((q) => q.id), ['d']);
      },
    );

    test('wrong answers mark cards only once the run is evaluated', () async {
      final l = await lesson();
      final run = (await repo.startOrResume(l, 's1'))!;
      await repo.answer(run.$1.id, run.$2[0], 3); // a: wrong
      expect(
        (await planner(l)).markedAnchors(),
        isEmpty,
        reason: 'run still open: no marks yet',
      );

      // Leaving and coming back the same day resumes the rest.
      final resumed = (await repo.startOrResume(l, 's1'))!;
      expect(resumed.$1.id, run.$1.id);
      expect(resumed.$2.map((q) => q.id), ['b']);
      await answerAll(resumed.$1, resumed.$2, {});
      expect((await planner(l)).markedAnchors(), ['k-a']);

      final result = await repo.result(l, run.$1.id);
      expect(result.correct, 1);
      expect(result.wrong.single.question.id, 'a');
    });

    test('an unfinished run is evaluated when its day is over', () async {
      final l = await lesson();
      final run = (await repo.startOrResume(l, 's1'))!;
      await repo.answer(run.$1.id, run.$2[0], 3); // a wrong, b never answered
      now = now.add(const Duration(days: 1));
      final p = await planner(l);
      expect(p.markedAnchors(), ['k-a']);
      // Next day: the wrong one, the skipped one and stage 2 come up.
      expect(p.due('s1').map((q) => q.id), ['a', 'b', 'c']);
    });

    test('a later right answer clears the mark', () async {
      final l = await lesson();
      final run = (await repo.startOrResume(l, 's1'))!;
      await answerAll(run.$1, run.$2, {'a': 2});
      expect((await planner(l)).markedAnchors(), ['k-a']);

      now = now.add(const Duration(days: 1));
      final next = (await repo.startOrResume(l, 's1'))!;
      expect(next.$2.map((q) => q.id), ['a', 'c']);
      await answerAll(next.$1, next.$2, {});
      expect((await planner(l)).markedAnchors(), isEmpty);
    });

    test('practice re-asks every unlocked question', () async {
      final l = await lesson();
      final run = (await repo.startOrResume(l, 's1'))!;
      await answerAll(run.$1, run.$2, {});
      final again = (await repo.startOrResume(l, 's1', practice: true))!;
      expect(again.$2.map((q) => q.id), ['a', 'b']);
      expect(again.$1.id, isNot(run.$1.id));
    });

    test('sections run independently', () async {
      final l = await lesson();
      final s1 = (await repo.startOrResume(l, 's1'))!;
      await answerAll(s1.$1, s1.$2, {});
      final p = await planner(l);
      expect(p.status('s2').started, isFalse);
      expect(p.status('s2').due, 1);
      expect(p.startDay('s1'), RecallDay.of(now));
    });

    test('upcoming lists stage 2 and 3 days for reminders', () async {
      final l = await lesson();
      final run = (await repo.startOrResume(l, 's1'))!;
      await answerAll(run.$1, run.$2, {});
      final today = RecallDay.of(now);
      final up = (await planner(l)).upcoming();
      expect(up.map((u) => (u.day - today, u.stage, u.count)), [
        (1, 2, 1),
        (7, 3, 1),
      ]);
    });

    test('list summary counts due questions and marks', () async {
      final l = await lesson();
      final run = (await repo.startOrResume(l, 's1'))!;
      await answerAll(run.$1, run.$2, {'b': 0});
      now = now.add(const Duration(days: 1));
      final summary = (await repo.watchLessons().first).single;
      expect(summary.sections, 2);
      expect(summary.questions, 5);
      expect(summary.started, 1);
      expect(summary.dueToday, 2); // b again + stage 2 c
      expect(summary.wrong, 1);
    });

    test('deleting a lesson removes its runs', () async {
      final l = await lesson();
      final run = (await repo.startOrResume(l, 's1'))!;
      await answerAll(run.$1, run.$2, {});
      await repo.delete(l.id);
      expect(await db.select(db.recallSessions).get(), isEmpty);
      expect(await db.select(db.recallAnswers).get(), isEmpty);
    });
  });

  test('RecallDay round-trips local days', () {
    final d = DateTime(2026, 3, 29, 23, 30); // DST change weekend
    expect(RecallDay.start(RecallDay.of(d)), DateTime(2026, 3, 29));
    expect(RecallDay.of(DateTime(2026, 3, 30, 0, 5)) - RecallDay.of(d), 1);
  });
}
