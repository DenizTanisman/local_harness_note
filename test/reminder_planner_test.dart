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
}
