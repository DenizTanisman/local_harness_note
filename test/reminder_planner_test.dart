import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/repositories/notes_repository.dart';
import 'package:local_harness_not/features/reminders/reminder_planner.dart';

void main() {
  const times = ['07:30', '14:00', '20:00'];

  test('three slots a day, in order', () {
    final s = ReminderPlanner.slots(
      after: DateTime(2026, 10, 16, 8),
      until: DateTime(2026, 10, 17, 15),
      times: times,
    );
    expect(s, [
      DateTime(2026, 10, 16, 14),
      DateTime(2026, 10, 16, 20),
      DateTime(2026, 10, 17, 7, 30),
      DateTime(2026, 10, 17, 14),
    ]);
  });

  test('plan walks the list in order and loops', () {
    final (plan, cursor) = ReminderPlanner.plan(
      now: DateTime(2026, 10, 16, 8),
      times: times,
      ids: ['a', 'b'],
      cursor: const ReminderCursor(null, null),
      horizonDays: 2,
    );
    expect(plan.take(4).map((p) => p.noteId), ['a', 'b', 'a', 'b']);
    expect(plan.first.when, DateTime(2026, 10, 16, 14));
    expect(
      cursor,
      ReminderCursor('a', DateTime(2026, 10, 16, 14).millisecondsSinceEpoch),
    );
  });

  test('advance counts fired slots since the cursor', () {
    final cursor = ReminderCursor(
      'a',
      DateTime(2026, 10, 16, 14).millisecondsSinceEpoch,
    );
    // 14:00 (a) and 20:00 (b) fired; 07:30 next day → c.
    final next = ReminderPlanner.advance(
      now: DateTime(2026, 10, 16, 21),
      times: times,
      ids: ['a', 'b', 'c'],
      cursor: cursor,
    );
    expect(next.noteId, 'c');
    expect(next.slot, DateTime(2026, 10, 17, 7, 30).millisecondsSinceEpoch);
    // Three days later the list has looped: 1 + 8 fired = 9 → back to a.
    final later = ReminderPlanner.advance(
      now: DateTime(2026, 10, 19, 13),
      times: times,
      ids: ['a', 'b', 'c'],
      cursor: cursor,
    );
    expect(later.noteId, 'a');
  });

  test('a future cursor stays put', () {
    final cursor = ReminderCursor(
      'b',
      DateTime(2026, 10, 16, 14).millisecondsSinceEpoch,
    );
    expect(
      ReminderPlanner.advance(
        now: DateTime(2026, 10, 16, 9),
        times: times,
        ids: ['a', 'b'],
        cursor: cursor,
      ),
      cursor,
    );
  });

  test('empty list → no reminders', () {
    final (plan, cursor) = ReminderPlanner.plan(
      now: DateTime(2026, 10, 16, 8),
      times: times,
      ids: const [],
      cursor: const ReminderCursor('x', 1),
    );
    expect(plan, isEmpty);
    expect(cursor, const ReminderCursor(null, null));
  });

  test('reordering keeps the next item next (repository)', () async {
    var now = DateTime(2026, 10, 16, 8);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = NotesRepository(db, clock: () => now);
    final ids = [
      for (final b in ['a', 'b', 'c', 'd']) await repo.create(b),
    ];
    for (final id in ids) {
      await repo.addToReminders(id);
    }
    // Schedule from 08:00: a@14, b@20, c@07:30 …
    final (_, c0) = ReminderPlanner.plan(
      now: now,
      times: times,
      ids: ids,
      cursor: await repo.loadCursor(),
    );
    await repo.saveCursor(c0);
    // 14:00 and 20:00 fired → c is next. Then the user moves c to the end.
    now = DateTime(2026, 10, 16, 21);
    await repo.reorderReminders([ids[0], ids[1], ids[3], ids[2]]);
    final cursor = await repo.loadCursor();
    expect(cursor.noteId, ids[2]);
    final (plan, _) = ReminderPlanner.plan(
      now: now,
      times: times,
      ids: [ids[0], ids[1], ids[3], ids[2]],
      cursor: cursor,
      horizonDays: 2,
    );
    // c, then wraps to a, b, d …
    expect(plan.take(4).map((p) => p.noteId), [ids[2], ids[0], ids[1], ids[3]]);
    await db.close();
  });

  group('reminders by length', () {
    const min = 60 * 1000;

    test('a note goes out by its clip: 3–8 min morning, shorter midday, '
        'longer or text only evening', () {
      expect(ReminderKind.ofNote(null), ReminderKind.evening);
      expect(ReminderKind.ofNote(2 * min), ReminderKind.midday);
      expect(ReminderKind.ofNote(3 * min), ReminderKind.midday);
      expect(ReminderKind.ofNote(3 * min + 1000), ReminderKind.morning);
      expect(ReminderKind.ofNote(8 * min), ReminderKind.morning);
      expect(ReminderKind.ofNote(8 * min + 1000), ReminderKind.evening);
      expect(ReminderKind.ofTime('07:30'), ReminderKind.morning);
      expect(ReminderKind.ofTime('14:00'), ReminderKind.midday);
      expect(ReminderKind.ofTime('20:00'), ReminderKind.evening);
    });

    test('each part of the day walks its own notes and loops', () {
      final kinds = {
        'm1': ReminderKind.morning,
        'm2': ReminderKind.morning,
        'd1': ReminderKind.midday,
        'e1': ReminderKind.evening,
        'e2': ReminderKind.evening,
        'e3': ReminderKind.evening,
      };
      final (plan, cursors) = KindPlanner.plan(
        now: DateTime(2026, 10, 19, 6),
        times: const ['07:30', '14:00', '20:00'],
        ids: const ['e1', 'm1', 'd1', 'e2', 'm2', 'e3'],
        kinds: kinds,
        cursors: const {},
        horizonDays: 3,
      );
      String at(int day, int hour) => plan
          .firstWhere((p) => p.when.day == 19 + day && p.when.hour == hour)
          .noteId;
      expect([at(0, 7), at(0, 14), at(0, 20)], ['m1', 'd1', 'e1']);
      expect([at(1, 7), at(1, 14), at(1, 20)], ['m2', 'd1', 'e2']);
      expect([at(2, 7), at(2, 14), at(2, 20)], ['m1', 'd1', 'e3']);
      expect(cursors[ReminderKind.morning]!.noteId, 'm1');

      // A day later, each picks up where it was.
      final (later, _) = KindPlanner.plan(
        now: DateTime(2026, 10, 20, 6),
        times: const ['07:30', '14:00', '20:00'],
        ids: const ['e1', 'm1', 'd1', 'e2', 'm2', 'e3'],
        kinds: kinds,
        cursors: cursors,
        horizonDays: 1,
      );
      expect(later.where((p) => p.when.day == 20).map((p) => p.noteId), [
        'm2',
        'd1',
        'e2',
      ]);
    });

    test('a part of the day with no notes sends nothing', () {
      final (plan, _) = KindPlanner.plan(
        now: DateTime(2026, 10, 19, 6),
        times: const ['07:30', '14:00', '20:00'],
        ids: const ['e1'],
        kinds: const {'e1': ReminderKind.evening},
        cursors: const {},
        horizonDays: 1,
      );
      expect(
        plan.where((p) => p.when.day == 19).map((p) => p.when.hour),
        [20],
      );
    });
  });
}
