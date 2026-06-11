import 'dart:io';

import 'package:archive/archive.dart';
import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/io/backup_service.dart';
import 'package:daily_tracker/data/io/export_service.dart';
import 'package:daily_tracker/data/io/import_service.dart';
import 'package:daily_tracker/data/repositories/entry_repository.dart';
import 'package:daily_tracker/data/repositories/money_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 7 acceptance: export → fresh install import → identical data;
/// corrupt CSV rolls back FULLY; backup unreadable without the password.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> seedData() async {
    final entries = EntryRepository(db);
    final money = MoneyRepository(db);
    final software = await (db.select(db.metrics)
          ..where((m) => m.key.equals('software')))
        .getSingle();
    final brushing = await (db.select(db.metrics)
          ..where((m) => m.key.equals('brushing')))
        .getSingle();
    await entries.saveEntry(
        metricId: software.id,
        date: '2026-06-09',
        numValue: 45,
        textValue: 'parser, "tricky, quoted" text');
    final options = await (db.select(db.metricOptions)
          ..where((o) => o.metricId.equals(brushing.id)))
        .get();
    for (final option in options.take(2)) {
      await entries.setOptionSelected(
        metricId: brushing.id,
        optionId: option.id,
        date: '2026-06-09',
        selected: true,
      );
    }
    await money.addTransaction(
        date: '2026-06-09',
        direction: 'outcome',
        amount: 2000,
        category: 'Bill',
        subtype: 'home',
        note: 'electricity');
  }

  group('export → fresh import round trip', () {
    test('entries and transactions survive identically', () async {
      await seedData();
      final export = ExportService(db);
      final entriesCsv = await export.entriesCsv();
      final txCsv = await export.transactionsCsv();

      // Fresh install: a brand-new seeded database.
      final fresh = AppDatabase(NativeDatabase.memory());
      addTearDown(fresh.close);
      final importService = ImportService(fresh);
      final entryReport = await importService.importEntriesCsv(entriesCsv);
      final txReport = await importService.importTransactionsCsv(txCsv);
      expect(entryReport.skipped, isEmpty);
      expect(txReport.skipped, isEmpty);

      final software = await (fresh.select(fresh.metrics)
            ..where((m) => m.key.equals('software')))
          .getSingle();
      final entry = await (fresh.select(fresh.entries)
            ..where((e) => e.metricId.equals(software.id)))
          .getSingle();
      expect(entry.date, '2026-06-09');
      expect(entry.numValue, 45);
      expect(entry.textValue, 'parser, "tricky, quoted" text');

      final selected = await fresh.select(fresh.entryOptions).get();
      expect(selected, hasLength(2));

      final tx = await fresh.select(fresh.transactions).get();
      expect(tx, hasLength(1));
      expect(tx.single.category, 'Bill');
      expect(tx.single.subtype, 'home');
      expect(tx.single.amount, 2000);
      expect(tx.single.note, 'electricity');
    });

    test('re-import over existing data upserts without duplicating',
        () async {
      await seedData();
      final csv = await ExportService(db).entriesCsv();
      final report = await ImportService(db).importEntriesCsv(csv);
      expect(report.imported, 0);
      expect(report.overwritten, greaterThan(0));

      final software = await (db.select(db.metrics)
            ..where((m) => m.key.equals('software')))
          .getSingle();
      final rows = await (db.select(db.entries)
            ..where((e) => e.metricId.equals(software.id)))
          .get();
      expect(rows, hasLength(1));
    });
  });

  group('import validation (spec 10.2)', () {
    test('unknown metric_key and bad date are skipped and reported',
        () async {
      const csv = 'date,metric_key,num_value,text_value,selected_options\n'
          '2026-06-09,software,30,,\n'
          '2026-06-09,nope,1,,\n'
          'junk-date,water,2,,\n';
      final report = await ImportService(db).importEntriesCsv(csv);
      expect(report.imported, 1);
      expect(report.skipped, hasLength(2));
      expect(report.skipped[0], contains('unknown metric_key'));
      expect(report.skipped[1], contains('bad date'));
    });

    test('structurally corrupt row rolls back the WHOLE import', () async {
      const csv = 'date,metric_key,num_value,text_value,selected_options\n'
          '2026-06-09,software,30,,\n'
          '2026-06-10,water,not-a-number,,\n';
      await expectLater(ImportService(db).importEntriesCsv(csv),
          throwsA(isA<ImportFormatException>()));

      // The valid first row must NOT have been kept (full rollback).
      expect(await db.select(db.entries).get(), isEmpty);
    });

    test('wrong header rejected outright', () async {
      await expectLater(
          ImportService(db).importEntriesCsv('a,b,c\n1,2,3\n'),
          throwsA(isA<ImportFormatException>()));
    });
  });

  group('encrypted backup (spec 10.3)', () {
    test('backup decrypts with the right password into a valid ZIP',
        () async {
      await seedData();
      final service = BackupService(db);
      final encrypted = await service.createEncryptedBackup('hunter2');

      final zipBytes =
          await BackupService.decryptBackup(encrypted, 'hunter2');
      final archive = ZipDecoder().decodeBytes(zipBytes);
      expect(
        archive.files.map((f) => f.name),
        unorderedEquals([
          'entries.csv', 'transactions.csv', 'metrics.csv',
          'app_settings.json',
        ]),
      );
    });

    test('wrong password cannot open the backup', () async {
      final encrypted =
          await BackupService(db).createEncryptedBackup('correct');
      await expectLater(
          BackupService.decryptBackup(encrypted, 'wrong'),
          throwsA(anything));
    });

    test('backup bytes contain no plaintext CSV', () async {
      await seedData();
      final encrypted =
          await BackupService(db).createEncryptedBackup('hunter2');
      final asString = String.fromCharCodes(encrypted);
      expect(asString, isNot(contains('metric_key')));
      expect(asString, isNot(contains('Bill')));
    });

    test('prune keeps only the newest 8 backups', () async {
      final dir = await Directory.systemTemp.createTemp('dt_backups');
      addTearDown(() => dir.delete(recursive: true));
      final service = BackupService(db);
      for (var i = 1; i <= 10; i++) {
        await service.backupTo(dir, 'pw',
            now: DateTime(2026, 6, i, 3));
      }
      final remaining = dir
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .toList()
        ..sort();
      expect(remaining, hasLength(8));
      // The two oldest (June 1, June 2) were pruned.
      expect(remaining.first, contains('2026-06-03'));
    });

    test('weekly run lands on Sunday 03:00 strictly in the future', () {
      // 2026-06-11 is a Thursday → next Sunday is 06-14.
      expect(BackupService.nextWeeklyRun(DateTime(2026, 6, 11, 9)),
          DateTime(2026, 6, 14, 3));
      // Sunday after 03:00 → the following Sunday.
      expect(BackupService.nextWeeklyRun(DateTime(2026, 6, 14, 4)),
          DateTime(2026, 6, 21, 3));
      // Sunday before 03:00 → same day.
      expect(BackupService.nextWeeklyRun(DateTime(2026, 6, 14, 1)),
          DateTime(2026, 6, 14, 3));
    });
  });

  group('excel export', () {
    test('produces a non-empty xlsx with three sheets', () async {
      await seedData();
      final bytes = await ExportService(db).excelBytes();
      expect(bytes, isNotEmpty);
      // xlsx is a ZIP container.
      final archive = ZipDecoder().decodeBytes(bytes);
      final workbook = archive.files
          .firstWhere((f) => f.name == 'xl/workbook.xml');
      final xml = String.fromCharCodes(workbook.content as List<int>);
      for (final sheet in ['entries', 'transactions', 'metrics']) {
        expect(xml, contains(sheet));
      }
    });
  });

  group('sample CSV', () {
    test('sample parses through the importer without structural errors',
        () async {
      final report =
          await ImportService(db).importEntriesCsv(ExportService.sampleCsv());
      expect(report.imported, 3);
      expect(report.skipped, isEmpty);
    });
  });
}
