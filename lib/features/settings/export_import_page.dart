import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../data/io/export_service.dart';
import '../../data/io/import_service.dart';
import 'settings_providers.dart';

/// Export / Import (spec 6.6 + §10).
class ExportImportPage extends ConsumerWidget {
  const ExportImportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export / Import')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Export CSV'),
            subtitle: const Text('entries.csv, transactions.csv, metrics.csv'),
            onTap: () => _exportCsv(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.grid_on),
            title: const Text('Export Excel'),
            subtitle: const Text('Single .xlsx with three sheets'),
            onTap: () => _exportExcel(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download sample CSV'),
            onTap: () => _saveSample(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Import CSV'),
            subtitle: const Text('Template format; validated, all-or-nothing'),
            onTap: () => _importCsv(context, ref),
          ),
        ],
      ),
    );
  }

  /// Unencrypted-export warning (spec 10.1/§11.5) — shown before every export.
  Future<bool> _warnUnencrypted(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Heads up'),
        content: const Text(
          'Exported files are NOT encrypted. Keep them safe.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Export'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<String?> _pickDir(BuildContext context) async {
    if (!await _warnUnencrypted(context)) return null;
    return FilePicker.platform.getDirectoryPath();
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final dir = await _pickDir(context);
    if (dir == null) return;
    final export = ref.read(exportServiceProvider);
    await File(
      p.join(dir, 'entries.csv'),
    ).writeAsString(await export.entriesCsv());
    await File(
      p.join(dir, 'transactions.csv'),
    ).writeAsString(await export.transactionsCsv());
    await File(
      p.join(dir, 'metrics.csv'),
    ).writeAsString(await export.metricsCsv());
    messenger.showSnackBar(
      SnackBar(content: Text('Exported 3 CSV files to $dir')),
    );
  }

  Future<void> _exportExcel(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final dir = await _pickDir(context);
    if (dir == null) return;
    final bytes = await ref.read(exportServiceProvider).excelBytes();
    final file = File(p.join(dir, 'daily_tracker.xlsx'));
    await file.writeAsBytes(bytes);
    messenger.showSnackBar(SnackBar(content: Text('Exported ${file.path}')));
  }

  Future<void> _saveSample(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null) return;
    final file = File(p.join(dir, 'daily_tracker_sample.csv'));
    await file.writeAsString(ExportService.sampleCsv());
    messenger.showSnackBar(SnackBar(content: Text('Saved ${file.path}')));
  }

  Future<void> _importCsv(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    final path = picked?.files.single.path;
    if (path == null) return;
    final text = await File(path).readAsString();

    final importService = ref.read(importServiceProvider);
    try {
      final firstLine = text.split('\n').first.trim();
      final ImportReport report;
      if (firstLine == ExportService.transactionsHeader.join(',')) {
        report = await importService.importTransactionsCsv(text);
      } else {
        report = await importService.importEntriesCsv(text);
      }
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import finished'),
          content: Text(
            [
              'Imported: ${report.imported}',
              'Overwritten: ${report.overwritten}',
              if (report.skipped.isNotEmpty) ...[
                'Skipped ${report.skipped.length}:',
                ...report.skipped.take(10),
              ],
            ].join('\n'),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on ImportFormatException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Import rolled back completely: ${e.message}')),
      );
    }
  }
}
