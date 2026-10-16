import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/repositories/entry_repository.dart';
import 'package:local_harness_not/data/repositories/settings_repository.dart';
import 'package:local_harness_not/features/home/instagram_autofill.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR4-P2 acceptance (§3.3): Instagram auto-fill — auto writes/overwrites
/// auto days; a manual edit pins the day and is never overwritten; the
/// minutes now come from the Program app's hub snapshot
/// (`data.screenTime.days[].apps[]`) and the setting still gates it.
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

  group('instagramMinutesFromProgram (pure mapping)', () {
    Map<String, Object?> program(List<Object?> days) => {
      'app': 'program',
      'schema': 1,
      'data': {
        'screenTime': {'todayTotalMin': 120, 'top': const [], 'days': days},
      },
    };

    test('maps each day to its Instagram minutes', () {
      final minutes = instagramMinutesFromProgram(
        program([
          {
            'date': '2026-06-14',
            'totalMin': 200,
            'apps': [
              {'package': 'com.whatsapp', 'label': 'WhatsApp', 'min': 80},
              {
                'package': 'com.instagram.android',
                'label': 'Instagram',
                'min': 47,
              },
            ],
          },
          {
            'date': '2026-06-13',
            'totalMin': 90,
            'apps': [
              // Program's rank-6 extra row: present even outside the top 5.
              {'package': 'com.instagram.android', 'label': null, 'min': 12.0},
            ],
          },
        ]),
      );
      expect(minutes, {'2026-06-14': 47.0, '2026-06-13': 12.0});
    });

    test('days without Instagram or with 0 minutes are left out', () {
      final minutes = instagramMinutesFromProgram(
        program([
          {
            'date': '2026-06-14',
            'totalMin': 10,
            'apps': [
              {'package': 'com.whatsapp', 'label': 'WhatsApp', 'min': 10},
            ],
          },
          {
            'date': '2026-06-13',
            'totalMin': 0,
            'apps': [
              {'package': 'com.instagram.android', 'label': 'IG', 'min': 0},
            ],
          },
        ]),
      );
      expect(minutes, isEmpty);
    });

    test('malformed or foreign snapshots map to nothing (no throw)', () {
      expect(instagramMinutesFromProgram(null), isEmpty);
      expect(instagramMinutesFromProgram({'app': 'para', 'data': {}}), isEmpty);
      expect(instagramMinutesFromProgram({'app': 'program'}), isEmpty);
      expect(
        instagramMinutesFromProgram({
          'app': 'program',
          'data': {
            'screenTime': {'days': 'nope'},
          },
        }),
        isEmpty,
      );
      expect(
        instagramMinutesFromProgram(
          program([
            'junk',
            {'date': 'yesterday', 'apps': []},
            {
              'date': '2026-06-14',
              'apps': [
                {'package': 'com.instagram.android', 'min': '47'},
              ],
            },
          ]),
        ),
        isEmpty,
      );
    });
  });

  group('InstagramAutofill.run', () {
    Map<String, Object?> snapshot(int minutes) => {
      'app': 'program',
      'schema': 1,
      'data': {
        'screenTime': {
          'days': [
            {
              'date': '2026-06-13',
              'totalMin': minutes,
              'apps': [
                {
                  'package': 'com.instagram.android',
                  'label': 'Instagram',
                  'min': minutes,
                },
              ],
            },
          ],
        },
      },
    };

    test('enabled (default) → Instagram filled from the snapshot', () async {
      final requested = <String>[];
      final autofill = InstagramAutofill(
        entries,
        SettingsRepository(db),
        readPeer: (app) async {
          requested.add(app);
          return snapshot(63);
        },
      );
      expect(await autofill.run(), 1);
      expect(requested, ['program']);
      final e = await instagramEntry('2026-06-13');
      expect(e!.numValue, 63);
      expect(e.valueSource, 'auto');
    });

    test('setting off → no read, no write', () async {
      await SettingsRepository(db).set('autofill_instagram', 'false');
      var reads = 0;
      final autofill = InstagramAutofill(
        entries,
        SettingsRepository(db),
        readPeer: (_) async {
          reads++;
          return snapshot(63);
        },
      );
      expect(await autofill.run(), 0);
      expect(reads, 0);
      expect(await instagramEntry('2026-06-13'), isNull);
    });

    test('Program not installed (null snapshot) → silent no-op', () async {
      final autofill = InstagramAutofill(
        entries,
        SettingsRepository(db),
        readPeer: (_) async => null,
      );
      expect(await autofill.run(), 0);
      expect(await db.select(db.entries).get(), isEmpty);
    });

    test('default reader without a platform side is a no-op', () async {
      // No readPeer override → HubBridge → MissingPluginException → null.
      TestWidgetsFlutterBinding.ensureInitialized();
      final autofill = InstagramAutofill(entries, SettingsRepository(db));
      expect(await autofill.run(), 0);
    });

    test('a manual day is never overwritten by the snapshot', () async {
      final ig = await (db.select(
        db.metrics,
      )..where((m) => m.key.equals('instagram'))).getSingle();
      await entries.saveEntry(metricId: ig.id, date: '2026-06-13', numValue: 5);
      final autofill = InstagramAutofill(
        entries,
        SettingsRepository(db),
        readPeer: (_) async => snapshot(90),
      );
      expect(await autofill.run(), 0);
      final e = await instagramEntry('2026-06-13');
      expect(e!.numValue, 5);
      expect(e.valueSource, 'manual');
    });
  });
}
