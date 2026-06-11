import '../../core/date_key.dart';
import 'quote_service.dart';

/// What to schedule, computed purely so it can be unit-tested.
/// The thin plugin layer (NotificationService) just applies this list.
class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.when,
    required this.title,
    this.body,
    required this.payload,
  });

  final int id;
  final DateTime when;
  final String title;
  final String? body;

  /// 'home' | 'money' — tap routing (spec §8).
  final String payload;
}

/// An unfired expense reminder row (id + date + CATEGORY ONLY — amounts
/// never reach the notification layer, spec §8/§11.4).
class ReminderInput {
  const ReminderInput({
    required this.id,
    required this.remindDate,
    required this.category,
  });

  final int id;
  final String remindDate;
  final String category;
}

class NotificationPlanner {
  /// Days of morning/evening notifications scheduled ahead; the set is
  /// refreshed on every app open and on boot.
  static const horizonDays = 14;

  static const morningBaseId = 1000;
  static const eveningBaseId = 2000;
  static const expenseBaseId = 30000;
  static const expenseHour = 10;

  /// [morning]/[evening] are 'HH:mm'. [missingToday] is the number of
  /// unfilled cards right now (appended to tonight's reminder only).
  static List<PlannedNotification> plan({
    required DateTime now,
    required String morning,
    required String evening,
    required bool quotesEnabled,
    required List<String> quotes,
    required int missingToday,
    required List<ReminderInput> reminders,
  }) {
    final result = <PlannedNotification>[];

    DateTime at(DateTime day, String hhmm) {
      final parts = hhmm.split(':').map(int.parse).toList();
      return DateTime(day.year, day.month, day.day, parts[0], parts[1]);
    }

    for (var i = 0; i < horizonDays; i++) {
      final day = now.add(Duration(days: i));

      if (quotesEnabled && quotes.isNotEmpty) {
        final when = at(day, morning);
        if (when.isAfter(now)) {
          result.add(PlannedNotification(
            id: morningBaseId + i,
            when: when,
            title: 'Good morning',
            body: QuoteService.quoteFor(quotes, day),
            payload: 'home',
          ));
        }
      }

      final eveningAt = at(day, evening);
      if (eveningAt.isAfter(now)) {
        final isToday = i == 0;
        result.add(PlannedNotification(
          id: eveningBaseId + i,
          when: eveningAt,
          title: 'Time to fill in your day',
          body: isToday && missingToday > 0
              ? '$missingToday item${missingToday == 1 ? '' : 's'} left'
              : null,
          payload: 'home',
        ));
      }
    }

    final today = dateKey(now);
    for (final reminder in reminders) {
      if (reminder.remindDate.compareTo(today) < 0) continue;
      final when = at(parseDateKey(reminder.remindDate), '$expenseHour:00');
      if (!when.isAfter(now)) continue;
      // CATEGORY NAME ONLY — never the amount (lock-screen leak, spec §8).
      result.add(PlannedNotification(
        id: expenseBaseId + reminder.id,
        when: when,
        title: 'Reminder: ${reminder.category}',
        payload: 'money',
      ));
    }

    return result;
  }
}
