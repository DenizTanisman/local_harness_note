import 'package:csv/csv.dart';
import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'export_service.dart';

/// Per-file report shown to the user after import (spec 10.2).
class ImportReport {
  ImportReport();

  int imported = 0;
  int overwritten = 0;
  final List<String> skipped = []; // 'row N: reason'

  @override
  String toString() =>
      'imported $imported, overwritten $overwritten, skipped ${skipped.length}';
}

/// Thrown on structural corruption — the surrounding DB transaction rolls
/// back COMPLETELY (spec 10.2 acceptance: partial imports never happen).
class ImportFormatException implements Exception {
  ImportFormatException(this.message);

  final String message;

  @override
  String toString() => 'ImportFormatException: $message';
}

class ImportService {
  ImportService(this.db);

  final AppDatabase db;

  static final _dateRe = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  /// Imports an entries.csv in the export format. Unknown metric_key or
  /// bad date → row skipped and reported; structural errors (wrong column
  /// count, unparsable number) → ImportFormatException → full rollback.
  Future<ImportReport> importEntriesCsv(String csvText) async {
    const parser = CsvDecoder();
    final rows = parser
        .convert(csvText.replaceAll('\r\n', '\n'))
        .where((r) => r.isNotEmpty && r.join().trim().isNotEmpty)
        .toList();
    if (rows.isEmpty) throw ImportFormatException('empty file');
    final header = rows.first.map((c) => c.toString().trim()).toList();
    if (header.join(',') != ExportService.entriesHeader.join(',')) {
      throw ImportFormatException('unexpected header: ${header.join(',')}');
    }

    final report = ImportReport();
    await db.transaction(() async {
      final metrics = await db.select(db.metrics).get();
      final metricByKey = {for (final m in metrics) m.key: m};
      final options = await db.select(db.metricOptions).get();

      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length != ExportService.entriesHeader.length) {
          throw ImportFormatException(
            'row ${i + 1}: expected ${ExportService.entriesHeader.length} '
            'columns, got ${row.length}',
          );
        }
        final date = row[0].toString().trim();
        final key = row[1].toString().trim();
        final numRaw = row[2].toString().trim();
        final text = row[3].toString();
        final selected = row[4].toString().trim();

        final metric = metricByKey[key];
        if (metric == null) {
          report.skipped.add('row ${i + 1}: unknown metric_key "$key"');
          continue;
        }
        if (!_dateRe.hasMatch(date)) {
          report.skipped.add('row ${i + 1}: bad date "$date"');
          continue;
        }
        double? numValue;
        if (numRaw.isNotEmpty) {
          numValue = double.tryParse(numRaw);
          if (numValue == null) {
            throw ImportFormatException(
              'row ${i + 1}: unparsable num_value "$numRaw"',
            );
          }
        }

        final existing =
            await (db.select(db.entries)..where(
                  (e) => e.metricId.equals(metric.id) & e.date.equals(date),
                ))
                .getSingleOrNull();
        final now = DateTime.now().millisecondsSinceEpoch;
        await db.upsertEntry(
          EntriesCompanion.insert(
            metricId: metric.id,
            date: date,
            numValue: Value(numValue),
            textValue: Value(text.isEmpty ? null : text),
            createdAt: now,
            updatedAt: now,
          ),
        );
        existing == null ? report.imported++ : report.overwritten++;

        // Re-link selected options by label.
        final entry =
            await (db.select(db.entries)..where(
                  (e) => e.metricId.equals(metric.id) & e.date.equals(date),
                ))
                .getSingle();
        await (db.delete(
          db.entryOptions,
        )..where((eo) => eo.entryId.equals(entry.id))).go();
        if (selected.isNotEmpty) {
          for (final label in selected.split(';')) {
            final option = options
                .where(
                  (o) => o.metricId == metric.id && o.label == label.trim(),
                )
                .firstOrNull;
            if (option == null) {
              report.skipped.add(
                'row ${i + 1}: unknown option "$label" for $key',
              );
              continue;
            }
            await db
                .into(db.entryOptions)
                .insert(
                  EntryOptionsCompanion.insert(
                    entryId: entry.id,
                    optionId: option.id,
                  ),
                  mode: InsertMode.insertOrIgnore,
                );
          }
        }
      }
    });
    return report;
  }
}
