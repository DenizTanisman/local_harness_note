import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_key.dart';
import '../../data/db/database_provider.dart';
import '../../data/repositories/screen_time_repository.dart';
import '../home/home_providers.dart';
import '../settings/settings_providers.dart';
import 'usage_stats_source.dart';

/// Instagram's package — its measured minutes auto-fill the metric (§3.3).
const instagramPackage = 'com.instagram.android';

/// Swapped for a fake in tests.
final screenTimeSourceProvider = Provider<ScreenTimeSource>(
  (ref) => const UsageStatsSource(),
);

final screenTimeRepositoryProvider = Provider<ScreenTimeRepository>((ref) {
  final entries = ref.watch(entryRepositoryProvider);
  return ScreenTimeRepository(
    ref.watch(databaseProvider),
    ref.watch(screenTimeSourceProvider),
    onSynced: (date, raw) async {
      // CR-4 §3.3: auto-fill Instagram minutes when the setting is on
      // (default on). Manual edits win (handled in autofillInstagram).
      final settings = await ref.read(settingsRepositoryProvider).loadAll();
      if (settings['autofill_instagram'] == 'false') return;
      final ig = raw[instagramPackage];
      if (ig == null) return;
      await entries.autofillInstagram(
        date: date,
        minutes: ig.foregroundMinutes.toDouble(),
      );
    },
  );
});

/// Stored screen time for a given day (read from DB; populated by sync).
final screenTimeProvider = StreamProvider.family<ScreenTimeDayData?, String>(
  (ref, date) => ref.watch(screenTimeRepositoryProvider).watch(date),
);

/// Today's stored screen time (Main summary + Health section).
final todayScreenTimeProvider = StreamProvider<ScreenTimeDayData?>(
  (ref) =>
      ref.watch(screenTimeRepositoryProvider).watch(dateKey(DateTime.now())),
);

/// Whether Usage Access is granted (drives onboarding vs data).
final screenTimePermissionProvider = FutureProvider<bool>(
  (ref) => ref.watch(screenTimeRepositoryProvider).hasPermission(),
);
