import 'dart:convert';
import 'dart:io';

import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/db/open_connection.dart';
import 'package:local_harness_not/data/repositories/notes_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('database file contains no plaintext (phase 0 acceptance)', () async {
    final dir = await Directory.systemTemp.createTemp('local_harness_not_enc');
    final file = File(p.join(dir.path, 'enc_test.db'));
    const key =
        '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';
    const canary = 'PLAINTEXT_CANARY_SHOULD_NOT_LEAK';

    var db = AppDatabase(encryptedExecutor(file, key));
    final id = await NotesRepository(db).create('$canary #gizli');
    await db.close();

    final bytes = await file.readAsBytes();
    final asLatin1 = latin1.decode(bytes, allowInvalid: true);
    expect(
      asLatin1,
      isNot(contains('SQLite format 3')),
      reason: 'unencrypted SQLite header found',
    );
    expect(
      asLatin1,
      isNot(contains(canary)),
      reason: 'user text stored in plaintext',
    );
    expect(
      asLatin1,
      isNot(contains('canary')),
      reason: 'search index stored in plaintext',
    );

    // Sanity: the right key still opens it and data round-trips.
    db = AppDatabase(encryptedExecutor(file, key));
    final repo = NotesRepository(db);
    expect((await repo.getNote(id))!.body, '$canary #gizli');
    expect(await repo.search(query: 'plaintext canary'), hasLength(1));
    await db.close();

    // Wrong key must NOT open the database.
    final wrongDb = AppDatabase(encryptedExecutor(file, 'deadbeef' * 8));
    await expectLater(wrongDb.select(wrongDb.notes).get(), throwsA(anything));
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
