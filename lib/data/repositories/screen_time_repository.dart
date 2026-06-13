import 'package:drift/drift.dart';

import '../../core/date_key.dart';
import '../db/app_database.dart';

/// One app's daily foreground time (CR-4 §4).
class AppUsage {
  const AppUsage({
    required this.packageName,
    required this.label,
    required this.foregroundMinutes,
  });

  final String packageName;
  final String label;
  final int foregroundMinutes;
}

/// A day's screen-time summary: total + top-5 apps (CR-4 §4).
class ScreenTimeDayData {
  const ScreenTimeDayData({
    required this.date,
    required this.totalMinutes,
    required this.topApps,
  });

  final String date;
  final int totalMinutes;
  final List<AppUsage> topApps;

  bool get isEmpty => topApps.isEmpty && totalMinutes == 0;
}

/// Device source of raw usage (CR-4 §4). UI never talks to it directly.
abstract class ScreenTimeSource {
  Future<bool> hasPermission();
  Future<void> openPermissionSettings();

  /// Raw per-package foreground minutes for [day]; null if unavailable.
  Future<Map<String, AppUsage>?> rawUsageFor(DateTime day);
}

/// Packages excluded from the top-5 (own app + common launchers/system UI).
const screenTimeExcluded = {
  'dev.deniz.daily_tracker',
  'com.google.android.apps.nexuslauncher',
  'com.sec.android.app.launcher',
  'com.android.systemui',
  'com.android.launcher',
  'com.miui.home',
};

/// Pure top-5 + total builder (CR-4 §4) — total over ALL usage, top-5 after
/// excluding our own app and launchers/system UI. Unit-testable.
ScreenTimeDayData buildScreenTimeDay(
  String date,
  Map<String, AppUsage> raw, {
  Set<String> exclude = screenTimeExcluded,
}) {
  final usable =
      raw.values
          .where(
            (u) => u.foregroundMinutes > 0 && !exclude.contains(u.packageName),
          )
          .toList()
        ..sort((a, b) => b.foregroundMinutes.compareTo(a.foregroundMinutes));
  final total = usable.fold<int>(0, (a, u) => a + u.foregroundMinutes);
  return ScreenTimeDayData(
    date: date,
    totalMinutes: total,
    topApps: usable.take(5).toList(),
  );
}

/// Stores fetched screen time and reads it back (CR-4 §5/§6). The total is
/// kept; only the top-5 app rows are persisted (data minimization).
class ScreenTimeRepository {
  ScreenTimeRepository(this.db, this.source);

  final AppDatabase db;
  final ScreenTimeSource source;

  Future<bool> hasPermission() => source.hasPermission();
  Future<void> openPermissionSettings() => source.openPermissionSettings();

  /// Pulls [day] (default today) and upserts it. Silently no-ops without
  /// permission — never a repeated pop-up (CR-4 §6). Returns what it stored.
  Future<ScreenTimeDayData?> sync({DateTime? day}) async {
    if (!await source.hasPermission()) return null;
    final d = day ?? DateTime.now();
    final raw = await source.rawUsageFor(d);
    if (raw == null) return null;
    final summary = buildScreenTimeDay(dateKey(d), raw);
    await _store(summary);
    return summary;
  }

  Future<void> _store(ScreenTimeDayData s) async {
    await db.transaction(() async {
      await db
          .into(db.screenTimeDay)
          .insertOnConflictUpdate(
            ScreenTimeDayCompanion(
              date: Value(s.date),
              totalMin: Value(s.totalMinutes),
              capturedAt: Value(DateTime.now().millisecondsSinceEpoch),
            ),
          );
      await (db.delete(
        db.screenTimeApp,
      )..where((a) => a.date.equals(s.date))).go();
      for (var i = 0; i < s.topApps.length; i++) {
        final app = s.topApps[i];
        await db
            .into(db.screenTimeApp)
            .insert(
              ScreenTimeAppCompanion.insert(
                date: s.date,
                packageName: app.packageName,
                appLabel: Value(app.label),
                foregroundMin: app.foregroundMinutes,
                rank: i + 1,
              ),
            );
      }
    });
  }

  Future<ScreenTimeDayData?> read(String date) async {
    final day = await (db.select(
      db.screenTimeDay,
    )..where((d) => d.date.equals(date))).getSingleOrNull();
    if (day == null) return null;
    final apps =
        await (db.select(db.screenTimeApp)
              ..where((a) => a.date.equals(date))
              ..orderBy([(a) => OrderingTerm.asc(a.rank)]))
            .get();
    return ScreenTimeDayData(
      date: date,
      totalMinutes: day.totalMin,
      topApps: [
        for (final a in apps)
          AppUsage(
            packageName: a.packageName,
            label: a.appLabel ?? a.packageName,
            foregroundMinutes: a.foregroundMin,
          ),
      ],
    );
  }

  Stream<ScreenTimeDayData?> watch(String date) => db
      .customSelect('SELECT 1', readsFrom: {db.screenTimeDay, db.screenTimeApp})
      .watch()
      .asyncMap((_) => read(date));
}
