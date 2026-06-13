import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/repositories/entry_repository.dart';
import 'package:daily_tracker/data/repositories/screen_time_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR4-P2 acceptance (§3.3): Instagram auto-fill — auto writes/overwrites
/// auto days; a manual edit pins the day and is never overwritten; the
/// onSynced hook respects the setting.
void main() {
  late AppDatabase db;
  late EntryRepository entries;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    entries = EntryRepository(db);
  });
  tearDown(() => db.close());

  Future<Entry?> instagramEntry(String date) async {
    final ig = await (db.select(
      db.metrics,
    )..where((m) => m.key.equals('instagram'))).getSingle();
    return (db.select(db.entries)
          ..where((e) => e.metricId.equals(ig.id))
          ..where((e) => e.date.equals(date)))
        .getSingleOrNull();
  }

  test('auto-fill writes num_value + stamps auto when no entry', () async {
    final wrote = await entries.autofillInstagram(
      date: '2026-06-13',
      minutes: 47,
    );
    expect(wrote, isTrue);
    final e = await instagramEntry('2026-06-13');
    expect(e!.numValue, 47);
    expect(e.valueSource, 'auto');
  });

  test('auto-fill overwrites a previous AUTO day', () async {
    await entries.autofillInstagram(date: '2026-06-13', minutes: 30);
    await entries.autofillInstagram(date: '2026-06-13', minutes: 52);
    final e = await instagramEntry('2026-06-13');
    expect(e!.numValue, 52);
    expect(e.valueSource, 'auto');
  });

  test('manual edit wins and is never overwritten', () async {
    final ig = await (db.select(
      db.metrics,
    )..where((m) => m.key.equals('instagram'))).getSingle();
    // User types the minutes + a reason manually.
    await entries.saveEntry(
      metricId: ig.id,
      date: '2026-06-13',
      numValue: 12,
      textValue: 'doomscrolling',
    );
    final wrote = await entries.autofillInstagram(
      date: '2026-06-13',
      minutes: 99,
    );
    expect(wrote, isFalse);
    final e = await instagramEntry('2026-06-13');
    expect(e!.numValue, 12, reason: 'manual minutes preserved');
    expect(e.valueSource, 'manual');
    expect(e.textValue, 'doomscrolling');
  });

  test('auto-fill preserves the manual "why" text on an auto day', () async {
    // Day starts auto, then user adds only the reason via the int_text body
    // — saveEntry marks it manual, so future fetch must not overwrite.
    await entries.autofillInstagram(date: '2026-06-13', minutes: 40);
    final ig = await (db.select(
      db.metrics,
    )..where((m) => m.key.equals('instagram'))).getSingle();
    await entries.saveEntry(
      metricId: ig.id,
      date: '2026-06-13',
      numValue: 40,
      textValue: 'reels',
      keepExistingNum: false,
    );
    final wrote = await entries.autofillInstagram(
      date: '2026-06-13',
      minutes: 88,
    );
    expect(wrote, isFalse);
    final e = await instagramEntry('2026-06-13');
    expect(e!.textValue, 'reels');
    expect(e.numValue, 40);
  });

  group('onSynced hook honours the setting', () {
    test('enabled (default) → Instagram filled from raw usage', () async {
      var enabled = true;
      final repo = ScreenTimeRepository(
        db,
        _Src({
          'com.instagram.android': const AppUsage(
            packageName: 'com.instagram.android',
            label: 'Instagram',
            foregroundMinutes: 63,
          ),
        }),
        onSynced: (date, raw) async {
          if (!enabled) return;
          final ig = raw['com.instagram.android'];
          if (ig != null) {
            await entries.autofillInstagram(
              date: date,
              minutes: ig.foregroundMinutes.toDouble(),
            );
          }
        },
      );
      await repo.sync(day: DateTime(2026, 6, 13));
      expect((await instagramEntry('2026-06-13'))!.numValue, 63);

      // disabled → no write on a fresh day
      enabled = false;
      await repo.sync(day: DateTime(2026, 6, 14));
      expect(await instagramEntry('2026-06-14'), isNull);
    });
  });
}

class _Src implements ScreenTimeSource {
  _Src(this.raw);
  final Map<String, AppUsage> raw;
  @override
  Future<bool> hasPermission() async => true;
  @override
  Future<void> openPermissionSettings() async {}
  @override
  Future<Map<String, AppUsage>?> rawUsageFor(DateTime day) async => raw;
}
