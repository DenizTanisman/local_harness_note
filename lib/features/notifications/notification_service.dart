import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../core/note_links.dart';
import '../../core/note_text.dart';
import '../../core/recall_planner.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/lessons_repository.dart';
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

  /// Lesson stage reminders ("ertesi gün", "bir hafta sonra") use ids from
  /// here on, at [lessonHour] o'clock of the day a stage opens.
  static const _lessonBaseId = 6000;
  static const lessonHour = 19;

  static const _lessonChannel = AndroidNotificationDetails(
    'not_lessons',
    'Ders tekrarları',
    channelDescription: 'Active recall: aşama 2 ve 3 zamanı gelince',
    importance: Importance.defaultImportance,
    styleInformation: BigTextStyleInformation(''),
  );

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
            db.lessons,
            db.recallSessions,
            db.recallAnswers,
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
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    // Exact when allowed (USE_EXACT_ALARM), so 07:30 means 07:30.
    final mode = await android?.canScheduleExactNotifications() == true
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
    await _scheduleLessons(mode);
    if (settings[remindersEnabledKey] == 'false') return;
    final byId = {for (final n in notes) n.id: n};
    for (var i = 0; i < plan.length; i++) {
      final note = byId[plan[i].noteId]!;
      final shown = NoteLinks.displayText(note.body);
      final title = NoteText.title(shown, max: 60);
      final rest = NoteText.rest(shown);
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

  /// One notification per lesson and day on which a later stage of a
  /// started section opens with questions still unanswered.
  Future<void> _scheduleLessons(AndroidScheduleMode mode) async {
    final now = DateTime.now();
    var id = _lessonBaseId;
    for (final (lesson, planner) in await LessonsRepository(db).allPlanners()) {
      final byDay = <int, List<({String section, int stage, int count})>>{};
      for (final u in planner.upcoming()) {
        (byDay[u.day] ??= []).add((
          section: u.section,
          stage: u.stage,
          count: u.count,
        ));
      }
      for (final MapEntry(key: day, value: items) in byDay.entries) {
        final start = RecallDay.start(day);
        final when = DateTime(start.year, start.month, start.day, lessonHour);
        if (!when.isAfter(now)) continue;
        final lines = [
          for (final i in items)
            '${planner.pack.section(i.section)?.title ?? i.section} · '
                'aşama ${i.stage} · ${i.count} soru',
        ];
        await _plugin.zonedSchedule(
          id: id++,
          title: '🧠 ${lesson.title}: tekrar zamanı',
          body: lines.join('\n'),
          scheduledDate: tz.TZDateTime.from(when, tz.local),
          notificationDetails: const NotificationDetails(
            android: _lessonChannel,
          ),
          androidScheduleMode: mode,
          payload: 'lesson:${lesson.id}:${items.first.section}',
        );
      }
    }
  }

  void dispose() {
    _watch?.cancel();
    _debounce?.cancel();
  }
}
