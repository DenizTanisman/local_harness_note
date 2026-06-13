import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/repositories/screen_time_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR4-P0 acceptance: top-5 selection/total, storage round-trip,
/// permission-gated silent sync.
class _FakeSource implements ScreenTimeSource {
  _FakeSource({this.granted = true, this.raw});

  bool granted;
  Map<String, AppUsage>? raw;
  int openCalls = 0;

  @override
  Future<bool> hasPermission() async => granted;
  @override
  Future<void> openPermissionSettings() async => openCalls++;
  @override
  Future<Map<String, AppUsage>?> rawUsageFor(DateTime day) async => raw;
}

AppUsage _u(String pkg, int min) =>
    AppUsage(packageName: pkg, label: pkg, foregroundMinutes: min);

void main() {
  group('buildScreenTimeDay (pure)', () {
    test('top-5 descending; total over all usable; excludes own/launcher', () {
      final raw = {
        'com.instagram.android': _u('com.instagram.android', 65),
        'com.whatsapp': _u('com.whatsapp', 38),
        'com.android.chrome': _u('com.android.chrome', 22),
        'com.google.youtube': _u('com.google.youtube', 19),
        'com.x': _u('com.x', 11),
        'com.extra': _u('com.extra', 5),
        'dev.deniz.daily_tracker': _u('dev.deniz.daily_tracker', 99), // own
        'com.sec.android.app.launcher': _u('com.sec.android.app.launcher', 40),
        'com.idle': _u('com.idle', 0), // zero filtered
      };
      final d = buildScreenTimeDay('2026-06-13', raw);
      expect(d.topApps.map((a) => a.packageName).toList(), [
        'com.instagram.android',
        'com.whatsapp',
        'com.android.chrome',
        'com.google.youtube',
        'com.x',
      ]);
      // Total = 65+38+22+19+11+5 (own app + launcher + zero excluded).
      expect(d.totalMinutes, 160);
    });

    test('empty raw → empty summary', () {
      final d = buildScreenTimeDay('2026-06-13', {});
      expect(d.isEmpty, isTrue);
    });
  });

  group('ScreenTimeRepository', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('sync stores total + only the top-5 rows; read round-trips', () async {
      final raw = {
        for (var i = 0; i < 8; i++) 'pkg$i': _u('pkg$i', (8 - i) * 10),
      };
      final repo = ScreenTimeRepository(db, _FakeSource(raw: raw));
      await repo.sync(day: DateTime(2026, 6, 13));

      final apps = await db.select(db.screenTimeApp).get();
      expect(apps, hasLength(5), reason: 'only top-5 persisted');
      final stored = await repo.read('2026-06-13');
      expect(stored!.totalMinutes, (8 + 7 + 6 + 5 + 4 + 3 + 2 + 1) * 10);
      expect(stored.topApps.first.packageName, 'pkg0'); // 80 min
      expect(stored.topApps.length, 5);
    });

    test('re-sync replaces the day rows (no duplicates)', () async {
      final repo = ScreenTimeRepository(
        db,
        _FakeSource(raw: {'a': _u('a', 30), 'b': _u('b', 10)}),
      );
      await repo.sync(day: DateTime(2026, 6, 13));
      await repo.sync(day: DateTime(2026, 6, 13));
      final apps = await db.select(db.screenTimeApp).get();
      expect(apps, hasLength(2));
    });

    test('no permission → silent skip, nothing stored', () async {
      final repo = ScreenTimeRepository(
        db,
        _FakeSource(granted: false, raw: {'a': _u('a', 30)}),
      );
      final result = await repo.sync(day: DateTime(2026, 6, 13));
      expect(result, isNull);
      expect(await db.select(db.screenTimeDay).get(), isEmpty);
    });
  });
}
