import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../core/date_key.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/checkin_status.dart';
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
    'local_harness_not',
    'Not',
    channelDescription: 'Morning quotes and the evening check-in reminder',
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
      onDidReceiveNotificationResponse: (response) =>
          onTapPayload?.call(response.payload ?? 'home'),
    );
    // Android 13+ runtime permission (spec §8) — asked on first launch.
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
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
    // Uses the user's edited pool when present, else the bundled defaults.
    final quotes = quotesEnabled
        ? await QuoteService.effective(lang, settings)
        : <String>[];

    final plan = NotificationPlanner.plan(
      now: DateTime.now(),
      morning: settings['morning_time'] ?? '08:00',
      evening: settings['evening_time'] ?? '22:00',
      quotesEnabled: quotesEnabled,
      quotes: quotes,
      missingToday: await _missingToday(),
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

  /// Unfilled top-level check-in cards today (composites count as filled
  /// when any child is).
  Future<int> _missingToday() async =>
      (await loadCheckinStatus(db, dateKey(DateTime.now()))).missing.length;
}
