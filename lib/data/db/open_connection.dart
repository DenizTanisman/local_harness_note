import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const _dbKeyStorageKey = 'db_encryption_key';

/// 32 random bytes from [Random.secure] as 64 lowercase hex chars.
String generateDatabaseKey() {
  final random = Random.secure();
  return List.generate(32, (_) => random.nextInt(256))
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
}

/// Returns the database passphrase, generating and persisting it in the
/// Android Keystore (via flutter_secure_storage) on first launch.
/// The key never touches code, SharedPreferences or logs (spec 11.2).
Future<String> obtainDatabaseKey({FlutterSecureStorage? storage}) async {
  final secureStorage = storage ?? const FlutterSecureStorage();
  final existing = await secureStorage.read(key: _dbKeyStorageKey);
  if (existing != null) return existing;

  final key = generateDatabaseKey();
  await secureStorage.write(key: _dbKeyStorageKey, value: key);
  return key;
}

/// Encrypted executor for [file]. [hexKey] is always machine-generated hex,
/// so embedding it in the PRAGMA below is not an injection surface.
QueryExecutor encryptedExecutor(File file, String hexKey) {
  return NativeDatabase.createInBackground(
    file,
    setup: (db) {
      // The key must be applied before anything reads the database header.
      db.execute("PRAGMA key = '$hexKey'");
      // Fail loudly if the encryption-capable build did not load — never
      // fall back to a plaintext database (spec 11.1). On a plain build the
      // PRAGMA above is silently ignored and this function does not exist.
      try {
        db.select('SELECT sqlite3mc_version()');
      } on Object catch (e) {
        throw StateError('Encrypted SQLite build is not available: $e');
      }
    },
  );
}

/// Opens the production database with the key from secure storage.
QueryExecutor openEncryptedConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'daily_tracker.db'));
    final hexKey = await obtainDatabaseKey();
    return encryptedExecutor(file, hexKey);
  });
}
