import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database_provider.dart';
import '../../data/io/backup_service.dart';
import '../../data/io/export_service.dart';
import '../../data/io/import_service.dart';
import '../../data/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
    (ref) => SettingsRepository(ref.watch(databaseProvider)));

final settingsProvider = StreamProvider<Map<String, String>>(
    (ref) => ref.watch(settingsRepositoryProvider).watchAll());

final exportServiceProvider =
    Provider<ExportService>((ref) => ExportService(ref.watch(databaseProvider)));

final importServiceProvider =
    Provider<ImportService>((ref) => ImportService(ref.watch(databaseProvider)));

final backupServiceProvider =
    Provider<BackupService>((ref) => BackupService(ref.watch(databaseProvider)));
