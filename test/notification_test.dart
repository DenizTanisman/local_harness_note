import 'dart:convert';
import 'dart:io';

import 'package:local_harness_not/features/notifications/notification_planner.dart';
import 'package:local_harness_not/features/notifications/quote_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 6 acceptance (Not app — expense reminders moved to Para):
/// deterministic quote pick; evening missing count; only home-routed
/// notifications; boot recovery wiring.
void main() {
  final now = DateTime(2026, 6, 11, 9, 0); // 09:00, before evening

  List<PlannedNotification> planWith({
    int missing = 0,
    bool quotesEnabled = true,
    List<String> quotes = const ['q1', 'q2', 'q3'],
  }) => NotificationPlanner.plan(
    now: now,
    morning: '08:00',
    evening: '22:00',
    quotesEnabled: quotesEnabled,
    quotes: quotes,
    missingToday: missing,
  );

  group('plan content', () {
    test('every item routes home; ids stay in the quote/evening ranges', () {
      final plan = planWith(missing: 3);
      expect(plan, isNotEmpty);
      expect(plan.every((p) => p.payload == 'home'), isTrue);
      expect(
        plan.every(
          (p) =>
              p.id >= NotificationPlanner.morningBaseId &&
              p.id <
                  NotificationPlanner.eveningBaseId +
                      NotificationPlanner.horizonDays,
        ),
        isTrue,
      );
    });

    test('no TL-like amounts anywhere in the plan', () {
      for (final item in planWith(missing: 4)) {
        final text = '${item.title} ${item.body ?? ''}';
        expect(
          text.contains(RegExp(r'\d+([.,]\d+)?\s*TL')),
          isFalse,
          reason: text,
        );
      }
    });
  });

  group('morning quotes', () {
    test('deterministic dayOfYear % length pick', () {
      final quotes = ['a', 'b', 'c'];
      // 2026-06-11 is day 162 of the year; 162 % 3 == 0.
      expect(QuoteService.quoteFor(quotes, DateTime(2026, 6, 11)), 'a');
      expect(QuoteService.quoteFor(quotes, DateTime(2026, 6, 12)), 'b');
      // Same date always picks the same quote.
      expect(
        QuoteService.quoteFor(quotes, DateTime(2026, 6, 11)),
        QuoteService.quoteFor(quotes, DateTime(2026, 6, 11)),
      );
    });

    test('14-day horizon scheduled at the configured time', () {
      final plan = planWith();
      final mornings = plan
          .where(
            (p) =>
                p.id >= NotificationPlanner.morningBaseId &&
                p.id < NotificationPlanner.eveningBaseId,
          )
          .toList();
      expect(
        mornings,
        hasLength(NotificationPlanner.horizonDays - 1),
        reason: "today's 08:00 already passed at a 09:00 now",
      );
      expect(mornings.first.when.hour, 8);
      expect(mornings.every((p) => p.payload == 'home'), isTrue);
    });

    test('disabled quotes drop morning items only', () {
      final plan = planWith(quotesEnabled: false, quotes: []);
      expect(
        plan.where((p) => p.id < NotificationPlanner.eveningBaseId),
        isEmpty,
      );
      expect(
        plan.where((p) => p.id >= NotificationPlanner.eveningBaseId),
        isNotEmpty,
      );
    });
  });

  group('evening reminder', () {
    test("tonight's includes the missing count, later nights generic", () {
      final plan = planWith(missing: 4);
      final evenings = plan
          .where((p) => p.id >= NotificationPlanner.eveningBaseId)
          .toList();
      expect(evenings, hasLength(NotificationPlanner.horizonDays));
      expect(evenings.first.title, 'Time to fill in your day');
      expect(evenings.first.body, '4 items left');
      expect(evenings[1].body, isNull);
    });

    test('a single missing card reads "1 item left"', () {
      final tonight = planWith(
        missing: 1,
      ).firstWhere((p) => p.id == NotificationPlanner.eveningBaseId);
      expect(tonight.body, '1 item left');
    });

    test('zero missing → no count suffix', () {
      final plan = planWith(missing: 0);
      final tonight = plan.firstWhere(
        (p) => p.id == NotificationPlanner.eveningBaseId,
      );
      expect(tonight.body, isNull);
    });
  });

  group('quote pools', () {
    test('both asset pools hold ≥120 quotes (spec §8)', () {
      for (final lang in ['tr', 'en']) {
        final file = File('assets/quotes_$lang.json');
        expect(file.existsSync(), isTrue, reason: file.path);
        final list = (jsonDecode(file.readAsStringSync()) as List);
        expect(list.length, greaterThanOrEqualTo(120), reason: lang);
        expect(
          list.toSet().length,
          list.length,
          reason: '$lang has duplicates',
        );
      }
    });
  });

  group('boot recovery (spec §8)', () {
    test('manifest registers BOOT_COMPLETED receiver and permission', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      expect(manifest, contains('RECEIVE_BOOT_COMPLETED'));
      expect(manifest, contains('ScheduledNotificationBootReceiver'));
      expect(manifest, contains('POST_NOTIFICATIONS'));
      expect(
        manifest,
        isNot(contains('android.permission.SCHEDULE_EXACT_ALARM')),
        reason: 'inexact alarms by default',
      );
    });
  });
}
