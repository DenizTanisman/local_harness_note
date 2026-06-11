import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'open_connection.dart';

/// Single app-wide database instance. Overridden with an in-memory
/// executor in tests.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(openEncryptedConnection());
  ref.onDispose(db.close);
  return db;
});
