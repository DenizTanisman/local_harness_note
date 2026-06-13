import 'package:usage_stats/usage_stats.dart';

import '../../data/repositories/screen_time_repository.dart';

/// Real device source backed by Android's UsageStatsManager (CR-4 §1/§4).
/// Personal/sideload build → no Play permission policy applies.
class UsageStatsSource implements ScreenTimeSource {
  const UsageStatsSource();

  @override
  Future<bool> hasPermission() async =>
      (await UsageStats.checkUsagePermission()) ?? false;

  @override
  Future<void> openPermissionSettings() => UsageStats.grantUsagePermission();

  @override
  Future<Map<String, AppUsage>?> rawUsageFor(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final Map<String, UsageInfo> stats =
        await UsageStats.queryAndAggregateUsageStats(start, end);

    final result = <String, AppUsage>{};
    for (final entry in stats.entries) {
      final pkg = entry.value.packageName ?? entry.key;
      final fgMs = int.tryParse(entry.value.totalTimeInForeground ?? '0') ?? 0;
      final minutes = (fgMs / 60000).round();
      if (minutes <= 0) continue;
      // Resolve a human label; fall back to the package name.
      String label = pkg;
      try {
        final info = await UsageStats.getAppInfo(pkg);
        if (info?.appName != null && info!.appName!.isNotEmpty) {
          label = info.appName!;
        }
      } on Object {
        // Label resolution is best-effort; keep the package name.
      }
      result[pkg] = AppUsage(
        packageName: pkg,
        label: label,
        foregroundMinutes: minutes,
      );
    }
    return result;
  }
}
