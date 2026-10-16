import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../core/note_text.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/notes_repository.dart';
import '../reminders/reminder_planner.dart';

/// Thin plugin layer over [ReminderPlanner]: initializes the plugin and
/// applies the plan with zonedSchedule. Tapping a reminder opens its note
/// (payload `note:<id>`).
class NotificationService {
  NotificationService(this.db, {this.onTapPayload});

  final AppDatabase db;
  final void Function(String payload)? onTapPayload;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  StreamSubscription<void>? _watch;
  Timer? _debounce;

  static const remindersEnabledKey = 'reminders_enabled';
  static const _baseId = 3000;

  static const _channel = AndroidNotificationDetails(
    'not_reminders',
    'Hatırlatmalar',
    channelDescription: 'Hatırlatma listesinden sıradaki not',
    importance: Importance.defaultImportance,
    styleInformation: BigTextStyleInformation(''),
  );

  NotesRepository get _repo => NotesRepository(db);

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Fall back to the bundled default location.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (response) =>
          onTapPayload?.call(response.payload ?? ''),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  /// Payload of the notification that cold-started the app, if any.
  Future<String?> launchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return details!.notificationResponse?.payload;
  }

  /// Reschedules whenever notes or the reminder list change (debounced),
  /// so scheduled texts and order never go stale.
  void watchChanges() {
    _watch ??= db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            db.notes,
            db.reminders,
            db.appSettings,
          ]),
        )
        .listen((_) {
          _debounce?.cancel();
          _debounce = Timer(const Duration(seconds: 2), rescheduleAll);
        });
  }

  /// Recomputes and re-applies the whole schedule.
  Future<void> rescheduleAll() async {
    if (!_initialized) return;
    final settings = {
      for (final s in await db.select(db.appSettings).get()) s.key: s.value,
    };
    final notes = await _repo.reminderNotes();
    final (plan, cursor) = ReminderPlanner.plan(
      now: DateTime.now(),
      times: await _repo.reminderTimes(),
      ids: [for (final n in notes) n.id],
      cursor: await _repo.loadCursor(),
    );
    final current = await _repo.loadCursor();
    // Avoid a write → tableUpdates → reschedule loop.
    if (current != cursor) await _repo.saveCursor(cursor);

    // Only our reminders — cancelAll() would also take down the quick-note
    // bubble's notification.
    for (final pending in await _plugin.pendingNotificationRequests()) {
      if (pending.id >= _baseId) await _plugin.cancel(id: pending.id);
    }
    if (settings[remindersEnabledKey] == 'false') return;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    // Exact when allowed (USE_EXACT_ALARM), so 07:30 means 07:30.
    final mode = await android?.canScheduleExactNotifications() == true
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
    final byId = {for (final n in notes) n.id: n};
    for (var i = 0; i < plan.length; i++) {
      final note = byId[plan[i].noteId]!;
      final title = NoteText.title(note.body, max: 60);
      final rest = NoteText.rest(note.body);
      await _plugin.zonedSchedule(
        id: _baseId + i,
        title: '🔔 $title',
        body: rest.isEmpty
            ? null
            : (rest.length > 400 ? '${rest.substring(0, 400)}…' : rest),
        scheduledDate: tz.TZDateTime.from(plan[i].when, tz.local),
        notificationDetails: const NotificationDetails(android: _channel),
        androidScheduleMode: mode,
        payload: 'note:${note.id}',
      );
    }
  }

  void dispose() {
    _watch?.cancel();
    _debounce?.cancel();
  }
}
