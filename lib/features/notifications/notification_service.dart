import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../core/lesson_format.dart';
import '../../core/note_links.dart';
import '../../core/note_text.dart';
import '../../core/recall_planner.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/attachments_repository.dart';
import '../../data/repositories/lessons_repository.dart';
import '../../data/repositories/notes_repository.dart';
import '../reminders/reminder_planner.dart';
import 'notification_actions.dart';

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

  /// Previews use ids below the reminders' range, one per note, so two
  /// previews can be on screen together.
  static int _previewId(String noteId) =>
      2000 + (noteId.hashCode & 0x7fffffff) % 900;

  /// Lesson review reminders (1, 3 and 5 days after a section's first
  /// recall) use ids from here on.
  static const _lessonBaseId = 6000;

  static const _lessonChannel = AndroidNotificationDetails(
    'not_lessons',
    'Ders tekrarları',
    channelDescription: 'Active recall: 1, 3 ve 5 gün sonraki tekrarlar',
    importance: Importance.defaultImportance,
    styleInformation: BigTextStyleInformation(''),
  );

  /// A reminder: its picture (if any) shown large, and "▶ Oynat" when it
  /// has a voice clip — tapped, the clip plays without opening the app.
  static AndroidNotificationDetails _reminder({
    required String title,
    String? body,
    String? picture,
    String? clip,
    String? video,
  }) => AndroidNotificationDetails(
    'not_reminders',
    'Hatırlatmalar',
    channelDescription: 'Hatırlatma listesinden sıradaki not',
    importance: Importance.defaultImportance,
    styleInformation: picture == null
        ? const BigTextStyleInformation('')
        : BigPictureStyleInformation(
            FilePathAndroidBitmap(picture),
            largeIcon: FilePathAndroidBitmap(picture),
            contentTitle: title,
            summaryText: body,
            hideExpandedLargeIcon: true,
          ),
    largeIcon: picture == null ? null : FilePathAndroidBitmap(picture),
    actions: clip == null && video == null
        ? null
        : [
            if (clip != null)
              AndroidNotificationAction(
                playActionId(clip, title, image: picture),
                '▶ Oynat',
                cancelNotification: false,
              ),
            if (video != null)
              AndroidNotificationAction(
                watchActionId(video, title),
                '🎬 İzle',
                showsUserInterface: true,
                cancelNotification: false,
              ),
          ],
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
      onDidReceiveNotificationResponse: (response) async {
        if (await handleNotificationAction(response)) return;
        // "🎬 İzle" is taken by MainActivity (picture-in-picture).
        if (response.actionId?.startsWith(watchActionPrefix) ?? false) return;
        onTapPayload?.call(response.payload ?? '');
      },
      onDidReceiveBackgroundNotificationResponse: notificationActionBackground,
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
    final response = details!.notificationResponse;
    // "🎬 İzle" is played in picture-in-picture by MainActivity.
    if (response?.actionId?.startsWith(watchActionPrefix) ?? false) {
      return null;
    }
    return response?.payload;
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
            db.noteAttachments,
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
    final files = AttachmentsRepository(db);
    final media = await files.ofNotes(byId.keys);
    for (var i = 0; i < plan.length; i++) {
      final note = byId[plan[i].noteId]!;
      final r = await _reminderOf(note, media[note.id] ?? const [], files);
      await _plugin.zonedSchedule(
        id: _baseId + i,
        title: r.title,
        body: r.body,
        scheduledDate: tz.TZDateTime.from(plan[i].when, tz.local),
        notificationDetails: r.details,
        androidScheduleMode: mode,
        payload: 'note:${note.id}',
      );
    }
  }

  /// Title, text and look of a note's reminder notification.
  static Future<({String title, String? body, NotificationDetails details})>
  _reminderOf(
    Note note,
    List<NoteAttachment> attached,
    AttachmentsRepository files,
  ) async {
    final shown = NoteLinks.displayText(note.body);
    final title = '🔔 ${NoteText.title(shown, max: 60)}';
    final rest = NoteText.rest(shown);
    final body = rest.isEmpty
        ? null
        : (rest.length > 400 ? '${rest.substring(0, 400)}…' : rest);
    final voice = attached.where((a) => a.kind == 'audio').firstOrNull;
    final video = attached.where((a) => a.kind == 'video').firstOrNull;
    // ▶ Oynat plays the voice clip, or else the video's sound.
    final clip = voice ?? video;
    // The picture, or else the video's poster frame.
    final picture =
        attached.where((a) => a.kind == 'image').firstOrNull ?? video;
    return (
      title: title,
      body:
          body ??
          (voice != null
              ? '🎤 Sesli not'
              : video != null
              ? '🎬 Video'
              : null),
      details: NotificationDetails(
        android: _reminder(
          title: title,
          body: body,
          picture: picture == null
              ? null
              : (await files.notificationFileOf(picture))?.path,
          clip: clip == null ? null : (await files.fileOf(clip)).path,
          video: video == null ? null : (await files.fileOf(video)).path,
        ),
      ),
    );
  }

  /// Shows a note's reminder right now, exactly as it will arrive
  /// (Not › ⋮ › Bildirimi önizle). The plugin is a singleton, initialized
  /// at startup.
  static Future<void> preview(AppDatabase db, String noteId) async {
    final note = await NotesRepository(db).getNote(noteId);
    if (note == null) return;
    final files = AttachmentsRepository(db);
    final r = await _reminderOf(note, await files.of(noteId), files);
    await FlutterLocalNotificationsPlugin().show(
      id: _previewId(noteId),
      title: r.title,
      body: r.body,
      notificationDetails: r.details,
      payload: 'note:$noteId',
    );
  }

  /// One notification per started section for its 1-, 3- and 5-day
  /// reviews, at the time of day its first recall ran. Tapping it opens
  /// that section's test.
  Future<void> _scheduleLessons(AndroidScheduleMode mode) async {
    final now = DateTime.now();
    var id = _lessonBaseId;
    for (final (lesson, planner) in await LessonsRepository(db).allPlanners()) {
      for (final u in planner.upcoming()) {
        final first = DateTime.fromMillisecondsSinceEpoch(
          planner.startedAt(u.section)!,
        );
        final day = RecallDay.start(u.day);
        final when = DateTime(
          day.year,
          day.month,
          day.day,
          first.hour,
          first.minute,
        );
        if (!when.isAfter(now)) continue;
        final section = planner.pack.section(u.section)?.title ?? u.section;
        await _plugin.zonedSchedule(
          id: id++,
          title: '🧠 Recall: $section',
          body:
              '${lesson.title} · ${recallStageNames[u.stage]} · '
              '${u.count} soru',
          scheduledDate: tz.TZDateTime.from(when, tz.local),
          notificationDetails: const NotificationDetails(
            android: _lessonChannel,
          ),
          androidScheduleMode: mode,
          payload: 'recall:${lesson.id}:${u.section}',
        );
      }
    }
  }

  void dispose() {
    _watch?.cancel();
    _debounce?.cancel();
  }
}
