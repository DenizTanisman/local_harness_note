import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart';

import '../db/app_database.dart';

/// CSV / Excel export (spec 10.1). Three sheets/files:
/// entries, transactions, metrics.
class ExportService {
  ExportService(this.db);

  final AppDatabase db;

  static const entriesHeader = [
    'date', 'metric_key', 'num_value', 'text_value', 'selected_options',
  ];
  static const transactionsHeader = [
    'date', 'direction', 'category', 'subtype', 'amount', 'note',
  ];
  static const metricsHeader = [
    'key', 'title', 'parent_key', 'input_type', 'is_starred',
    'heatmap_label', 'unit',
  ];

  static const _csv = CsvEncoder(lineDelimiter: '\n');

  Future<String> entriesCsv() async {
    final rows = await (db.select(db.entries)
          ..orderBy([(e) => OrderingTerm.asc(e.date)]))
        .get();
    final metrics = await db.select(db.metrics).get();
    final keyById = {for (final m in metrics) m.id: m.key};

    final options = await db.select(db.metricOptions).get();
    final optionLabel = {for (final o in options) o.id: o.label};
    final entryOptions = await db.select(db.entryOptions).get();
    final labelsByEntry = <int, List<String>>{};
    for (final eo in entryOptions) {
      labelsByEntry
          .putIfAbsent(eo.entryId, () => [])
          .add(optionLabel[eo.optionId] ?? '');
    }

    return _csv.convert([
      entriesHeader,
      for (final e in rows)
        [
          e.date,
          keyById[e.metricId] ?? '',
          e.numValue ?? '',
          e.textValue ?? '',
          (labelsByEntry[e.id] ?? const []).join(';'),
        ],
    ]);
  }

  Future<String> transactionsCsv() async {
    final rows = await (db.select(db.transactions)
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
    return _csv.convert([
      transactionsHeader,
      for (final t in rows)
        [t.date, t.direction, t.category, t.subtype ?? '', t.amount, t.note ?? ''],
    ]);
  }

  Future<String> metricsCsv() async {
    final rows = await (db.select(db.metrics)
          ..orderBy([(m) => OrderingTerm.asc(m.sortOrder)]))
        .get();
    final keyById = {for (final m in rows) m.id: m.key};
    return _csv.convert([
      metricsHeader,
      for (final m in rows)
        [
          m.key,
          m.title,
          m.parentId != null ? (keyById[m.parentId] ?? '') : '',
          m.inputType,
          m.isStarred ? 1 : 0,
          m.heatmapLabel ?? '',
          m.unit ?? '',
        ],
    ]);
  }

  /// Same three sheets in one .xlsx (spec 10.1).
  Future<List<int>> excelBytes() async {
    final excel = Excel.createExcel();
    Future<void> sheetFrom(String name, String csvText) async {
      final sheet = excel[name];
      const parser = CsvDecoder();
      for (final row in parser.convert(csvText)) {
        sheet.appendRow([
          for (final cell in row) TextCellValue(cell.toString()),
        ]);
      }
    }

    await sheetFrom('entries', await entriesCsv());
    await sheetFrom('transactions', await transactionsCsv());
    await sheetFrom('metrics', await metricsCsv());
    excel.delete('Sheet1');
    return excel.encode()!;
  }

  /// "Download sample CSV" template — export format with 3 example rows
  /// (spec 10.2).
  static String sampleCsv() => _csv.convert([
        entriesHeader,
        ['2026-06-10', 'software', 45, 'Refactored the parser', ''],
        ['2026-06-10', 'water', 2.5, '', ''],
        ['2026-06-10', 'brushing', '', '', 'Morning;Evening'],
      ]);
}
