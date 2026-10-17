import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/app_database.dart';
import '../data/db/database_provider.dart';
import '../data/repositories/notes_repository.dart';
import '../features/reminders/reminder_planner.dart';
import 'date_key.dart';
import 'hub_bridge.dart';
import 'note_links.dart';
import 'note_text.dart';

/// Snapshot schema version served to the hub (docs/HUB_CONTRACT.md §4).
/// v2: second brain — note counts and the next reminder.
const hubSnapshotSchema = 2;

/// Builds the `not` hub snapshot — a pure function of the DB so it is
/// unit-testable with an in-memory database.
Future<Map<String, Object?>> buildHubSnapshot(
  AppDatabase db, {
  DateTime? now,
}) async {
  final at = now ?? DateTime.now();
  final repo = NotesRepository(db, clock: () => at);
  final counts = await repo.counts();
  final reminders = await repo.reminderNotes();
  final (plan, _) = ReminderPlanner.plan(
    now: at,
    times: await repo.reminderTimes(),
    ids: [for (final n in reminders) n.id],
    cursor: await repo.loadCursor(),
    horizonDays: 2,
  );
  Map<String, Object?>? next;
  if (plan.isNotEmpty) {
    final note = reminders.firstWhere((n) => n.id == plan.first.noteId);
    next = {
      // Private notes stay on the phone — the hub only learns one exists.
      'title': note.isPrivate
          ? '🔒'
          : NoteText.title(NoteLinks.displayText(note.body), max: 60),
      'at': plan.first.when.toIso8601String().substring(0, 19),
    };
  }

  final headline = counts.total == 0
      ? 'Henüz not yok'
      : '${counts.inbox} not gelen kutusunda'
            '${next == null ? '' : ' · sıradaki: ${next['title']}'}';

  return {
    'app': 'not',
    'schema': hubSnapshotSchema,
    // Millisecond precision, local time (contract example format).
    'generatedAt': DateTime.fromMillisecondsSinceEpoch(
      at.millisecondsSinceEpoch,
    ).toIso8601String(),
    'date': dateKey(at),
    'headline': headline,
    'data': {
      'notes': {'total': counts.total, 'inbox': counts.inbox},
      'nextReminder': next,
    },
  };
}

/// Keeps filesDir/hub_snapshot.json fresh (contract §5): once at startup,
/// debounced after every DB write, and when the app is backgrounded.
class HubSnapshotPublisher with WidgetsBindingObserver {
  HubSnapshotPublisher(
    this.db, {
    this.debounce = const Duration(milliseconds: 1500),
    Future<void> Function(Map<String, Object?> snapshot)? publish,
  }) : _publish = publish ?? HubBridge.publishSnapshot;

  final AppDatabase db;
  final Duration debounce;
  final Future<void> Function(Map<String, Object?> snapshot) _publish;

  StreamSubscription<Set<TableUpdate>>? _updates;
  Timer? _timer;
  bool _started = false;

  /// Publishes now and starts listening. Idempotent.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _updates = db.tableUpdates().listen((_) {
      _timer?.cancel();
      _timer = Timer(debounce, publishNow);
    });
    await publishNow();
  }

  Future<void> publishNow() async {
    _timer?.cancel();
    try {
      await _publish(await buildHubSnapshot(db));
    } catch (_) {
      // Best-effort: the hub just shows the previous snapshot. Never log
      // the payload (it carries the user's notes, spec §11.7).
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) publishNow();
  }

  void dispose() {
    _timer?.cancel();
    _updates?.cancel();
    if (_started) WidgetsBinding.instance.removeObserver(this);
  }
}

final hubSnapshotPublisherProvider = Provider<HubSnapshotPublisher>((ref) {
  final publisher = HubSnapshotPublisher(ref.watch(databaseProvider));
  ref.onDispose(publisher.dispose);
  return publisher;
});
