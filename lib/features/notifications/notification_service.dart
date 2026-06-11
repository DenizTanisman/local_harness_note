import 'package:drift/drift.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../data/db/app_database.dart';
import 'notification_planner.dart';
import 'quote_service.dart';

/// Thin plugin layer: everything decision-shaped lives in
/// NotificationPlanner; this class only initializes the plugin and applies
/// the plan with zonedSchedule.
class NotificationService {
  NotificationService(this.db, {this.onTapPayload});

  final AppDatabase db;
  final void Function(String payload)? onTapPayload;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channel = AndroidNotificationDetails(
    'daily_tracker',
    'Daily Tracker',
    channelDescription: 'Quotes and reminders',
    importance: Importance.defaultImportance,
  );

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
      onDidReceiveNotificationResponse: (response) {
        onTapPayload?.call(response.payload ?? 'home');
      },
    );
    // Android 13+ runtime permission (spec §8) — asked on first launch.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  /// Recomputes and re-applies the whole schedule. Called on app open;
  /// after a reboot the plugin's boot receiver restores what was scheduled.
  Future<void> rescheduleAll() async {
    if (!_initialized) return;
    final settings = {
      for (final s in await db.select(db.appSettings).get()) s.key: s.value,
    };
    final quotesEnabled = settings['quotes_enabled'] != 'false';
    final lang = settings['quote_lang'] ?? 'tr';
    final quotes = quotesEnabled ? await QuoteService.load(lang) : <String>[];

    final reminderJoin = db.select(db.expenseReminders).join([
      innerJoin(db.transactions,
          db.transactions.id.equalsExp(db.expenseReminders.transactionId)),
    ])
      ..where(db.expenseReminders.fired.equals(false));
    final reminders = [
      for (final row in await reminderJoin.get())
        ReminderInput(
          id: row.readTable(db.expenseReminders).id,
          remindDate: row.readTable(db.expenseReminders).remindDate,
          // Only the category crosses into the notification layer.
          category: row.readTable(db.transactions).category,
        ),
    ];

    final plan = NotificationPlanner.plan(
      now: DateTime.now(),
      morning: settings['morning_time'] ?? '08:00',
      evening: settings['evening_time'] ?? '22:00',
      quotesEnabled: quotesEnabled,
      quotes: quotes,
      missingToday: await _missingToday(),
      reminders: reminders,
    );

    await _plugin.cancelAll();
    for (final item in plan) {
      await _plugin.zonedSchedule(
        id: item.id,
        title: item.title,
        body: item.body,
        scheduledDate: tz.TZDateTime.from(item.when, tz.local),
        notificationDetails: const NotificationDetails(android: _channel),
        // Inexact by default — no SCHEDULE_EXACT_ALARM permission (spec §8).
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: item.payload,
      );
    }
  }

  Future<int> _missingToday() async {
    final today = DateTime.now();
    final date =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final top = await (db.select(db.metrics)
          ..where((m) => m.parentId.isNull()))
        .get();
    final dayEntries = await (db.select(db.entries)
          ..where((e) => e.date.equals(date)))
        .get();
    final filledIds = dayEntries.map((e) => e.metricId).toSet();
    final txCount = await (db.select(db.transactions)
          ..where((t) => t.date.equals(date)))
        .get();
    final children = await (db.select(db.metrics)
          ..where((m) => m.parentId.isNotNull()))
        .get();

    var missing = 0;
    for (final metric in top) {
      final filled = switch (metric.inputType) {
        'money' => txCount.isNotEmpty,
        'composite' => children
            .where((c) => c.parentId == metric.id)
            .any((c) => filledIds.contains(c.id)),
        _ => filledIds.contains(metric.id),
      };
      if (!filled) missing++;
    }
    return missing;
  }
}

