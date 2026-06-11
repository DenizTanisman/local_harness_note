import 'dart:convert';
import 'dart:io';

import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/open_connection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('database file contains no plaintext (phase 0 acceptance)', () async {
    final dir = await Directory.systemTemp.createTemp('daily_tracker_enc');
    final file = File(p.join(dir.path, 'enc_test.db'));
    const key =
        '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';
    const canary = 'PLAINTEXT_CANARY_SHOULD_NOT_LEAK';

    var db = AppDatabase(encryptedExecutor(file, key));
    final software = await (db.select(db.metrics)
          ..where((m) => m.key.equals('software')))
        .getSingle();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.upsertEntry(EntriesCompanion.insert(
      metricId: software.id,
      date: '2026-06-10',
      textValue: const Value(canary),
      createdAt: now,
      updatedAt: now,
    ));
    await db.close();

    final bytes = await file.readAsBytes();
    final asLatin1 = latin1.decode(bytes, allowInvalid: true);
    expect(asLatin1, isNot(contains('SQLite format 3')),
        reason: 'unencrypted SQLite header found');
    expect(asLatin1, isNot(contains(canary)),
        reason: 'user text stored in plaintext');
    expect(asLatin1, isNot(contains('Software')),
        reason: 'seed data stored in plaintext');

    // Sanity: the right key still opens it and data round-trips.
    db = AppDatabase(encryptedExecutor(file, key));
    final entry = await (db.select(db.entries)
          ..where((e) => e.metricId.equals(software.id)))
        .getSingle();
    expect(entry.textValue, canary);
    await db.close();

    // Wrong key must NOT open the database.
    final wrongDb = AppDatabase(
        encryptedExecutor(file, 'deadbeef' * 8));
    await expectLater(
        wrongDb.select(wrongDb.metrics).get(), throwsA(anything));
    await wrongDb.close();

    await dir.delete(recursive: true);
  });

  test('generated keys are 64 hex chars and unique', () {
    final a = generateDatabaseKey();
    final b = generateDatabaseKey();
    expect(a, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(a, isNot(b));
  });
}
