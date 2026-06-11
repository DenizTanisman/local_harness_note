import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:workmanager/workmanager.dart';

import '../../data/db/app_database.dart';
import '../../data/db/open_connection.dart';
import '../../data/io/backup_service.dart';

const weeklyBackupTask = 'weekly_backup';
const _backupPasswordKey = 'backup_password';

/// Background entry point — runs in its own isolate (spec 10.3).
@pragma('vm:entry-point')
void backupCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != weeklyBackupTask) return true;
    final db = AppDatabase(openEncryptedConnection());
    try {
      final settings = {
        for (final s in await db.select(db.appSettings).get()) s.key: s.value,
      };
      if (settings['backup_enabled'] != 'true') return true;
      final dir = settings['backup_dir_uri'];
      if (dir == null) return true;
      final password = await const FlutterSecureStorage().read(
        key: _backupPasswordKey,
      );
      if (password == null) return true;
      await BackupService(db).backupTo(Directory(dir), password);
      return true;
    } catch (_) {
      // Retry later; never log the password or file contents (spec §11.7).
      return false;
    } finally {
      await db.close();
    }
  });
}

class BackupScheduler {
  /// Weekly run anchored to Sunday 03:00 (spec 10.3), battery-friendly.
  static Future<void> register() async {
    final delay = BackupService.nextWeeklyRun(
      DateTime.now(),
    ).difference(DateTime.now());
    await Workmanager().registerPeriodicTask(
      weeklyBackupTask,
      weeklyBackupTask,
      frequency: const Duration(days: 7),
      initialDelay: delay,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }

  static Future<void> cancel() =>
      Workmanager().cancelByUniqueName(weeklyBackupTask);
}
