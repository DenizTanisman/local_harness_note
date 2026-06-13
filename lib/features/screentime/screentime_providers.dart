import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_key.dart';
import '../../data/db/database_provider.dart';
import '../../data/repositories/screen_time_repository.dart';
import 'usage_stats_source.dart';

/// Swapped for a fake in tests.
final screenTimeSourceProvider = Provider<ScreenTimeSource>(
  (ref) => const UsageStatsSource(),
);

final screenTimeRepositoryProvider = Provider<ScreenTimeRepository>(
  (ref) => ScreenTimeRepository(
    ref.watch(databaseProvider),
    ref.watch(screenTimeSourceProvider),
  ),
);

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
