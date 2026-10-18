/// Which reminder comes next: [noteId] is shown at [slot] (epoch ms; null
/// until the first schedule). Persisted in app_settings.
class ReminderCursor {
  const ReminderCursor(this.noteId, this.slot);

  final String? noteId;
  final int? slot;

  @override
  bool operator ==(Object other) =>
      other is ReminderCursor && other.noteId == noteId && other.slot == slot;

  @override
  int get hashCode => Object.hash(noteId, slot);

  @override
  String toString() => 'ReminderCursor($noteId, $slot)';
}

class PlannedReminder {
  const PlannedReminder({required this.when, required this.noteId});

  final DateTime when;
  final String noteId;
}

/// Sequential reminders (spec §6), as pure functions: the list is walked in
/// order, one item per daily slot (07:30 · 14:00 · 20:00 by default), and
/// starts over at the end.
class ReminderPlanner {
  ReminderPlanner._();

  /// Days scheduled ahead; refreshed on every app open and list change.
  static const horizonDays = 21;

  /// Every slot in (after, until] — [after] exclusive, [until] inclusive.
  static List<DateTime> slots({
    required DateTime after,
    required DateTime until,
    required List<String> times,
  }) {
    final parsed = [
      for (final t in times)
        (int.parse(t.split(':')[0]), int.parse(t.split(':')[1])),
    ]..sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
    final result = <DateTime>[];
    var day = DateTime(after.year, after.month, after.day);
    while (!day.isAfter(until)) {
      for (final (h, m) in parsed) {
        final at = DateTime(day.year, day.month, day.day, h, m);
        if (at.isAfter(after) && !at.isAfter(until)) result.add(at);
      }
      day = DateTime(day.year, day.month, day.day + 1);
    }
    return result;
  }

  static DateTime nextSlot(DateTime now, List<String> times) => slots(
    after: now,
    until: now.add(const Duration(days: 2)),
    times: times,
  ).first;

  /// Moves [cursor] past every slot that fired before [now]. The cursor's
  /// own slot counts as one shown item, plus each later slot up to [now].
  static ReminderCursor advance({
    required DateTime now,
    required List<String> times,
    required List<String> ids,
    required ReminderCursor cursor,
  }) {
    if (ids.isEmpty) return const ReminderCursor(null, null);
    var index = ids.indexOf(cursor.noteId ?? '');
    if (index < 0) index = 0;
    final slot = cursor.slot;
    if (slot == null) return ReminderCursor(ids[index], null);
    final at = DateTime.fromMillisecondsSinceEpoch(slot);
    if (at.isAfter(now)) return ReminderCursor(ids[index], slot);
    final fired = 1 + slots(after: at, until: now, times: times).length;
    return ReminderCursor(
      ids[(index + fired) % ids.length],
      nextSlot(now, times).millisecondsSinceEpoch,
    );
  }

  /// The schedule for the next [horizonDays] and the cursor to store.
  static (List<PlannedReminder>, ReminderCursor) plan({
    required DateTime now,
    required List<String> times,
    required List<String> ids,
    required ReminderCursor cursor,
    int horizonDays = horizonDays,
  }) {
    final current = advance(now: now, times: times, ids: ids, cursor: cursor);
    if (ids.isEmpty) return (const [], current);
    final upcoming = slots(
      after: now,
      until: now.add(Duration(days: horizonDays)),
      times: times,
    );
    final start = ids.indexOf(current.noteId!);
    return (
      [
        for (var i = 0; i < upcoming.length; i++)
          PlannedReminder(
            when: upcoming[i],
            noteId: ids[(start + i) % ids.length],
          ),
      ],
      ReminderCursor(current.noteId, upcoming.first.millisecondsSinceEpoch),
    );
  }
}

/// Which daily reminder a note goes out at, by the length of its voice clip
/// or video (the user's rule):
/// - morning: longer than 3 min, up to 8 min;
/// - midday: 3 min or shorter;
/// - evening: longer than 8 min — and notes with text only.
enum ReminderKind {
  morning('Sabah'),
  midday('Öğle'),
  evening('Akşam');

  const ReminderKind(this.label);
  final String label;

  static const _short = Duration(minutes: 3);
  static const _long = Duration(minutes: 8);

  /// [mediaMs]: the longest voice clip / video of the note, null when it
  /// has none (or its length is unknown).
  static ReminderKind ofNote(int? mediaMs) {
    if (mediaMs == null) return evening;
    final length = Duration(milliseconds: mediaMs);
    if (length <= _short) return midday;
    if (length <= _long) return morning;
    return evening;
  }

  /// A reminder time's part of the day: before 12:00 morning, until 17:00
  /// midday, later evening.
  static ReminderKind ofTime(String hhmm) {
    final hour = int.parse(hhmm.split(':')[0]);
    if (hour < 12) return morning;
    if (hour < 17) return midday;
    return evening;
  }
}

/// [ReminderPlanner] run once per [ReminderKind]: each part of the day walks
/// its own notes, in list order, and starts over at their end.
class KindPlanner {
  KindPlanner._();

  static (List<PlannedReminder>, Map<ReminderKind, ReminderCursor>) plan({
    required DateTime now,
    required List<String> times,
    required List<String> ids,
    required Map<String, ReminderKind> kinds,
    required Map<ReminderKind, ReminderCursor> cursors,
    int horizonDays = ReminderPlanner.horizonDays,
  }) {
    final planned = <PlannedReminder>[];
    final next = <ReminderKind, ReminderCursor>{};
    for (final kind in ReminderKind.values) {
      final kindTimes = [
        for (final t in times)
          if (ReminderKind.ofTime(t) == kind) t,
      ];
      final kindIds = [
        for (final id in ids)
          if ((kinds[id] ?? ReminderKind.evening) == kind) id,
      ];
      if (kindTimes.isEmpty) continue;
      final (list, cursor) = ReminderPlanner.plan(
        now: now,
        times: kindTimes,
        ids: kindIds,
        cursor: cursors[kind] ?? const ReminderCursor(null, null),
        horizonDays: horizonDays,
      );
      planned.addAll(list);
      next[kind] = cursor;
    }
    planned.sort((a, b) => a.when.compareTo(b.when));
    return (planned, next);
  }
}
