import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart'
    show BooleanExpressionOperators, OrderingTerm, Value;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/db/app_database.dart';
import '../../data/db/database_provider.dart';
import '../../data/heatmap/heatmap_rule.dart';
import '../../main.dart' show notificationServiceProvider;
import '../backup/backup_worker.dart';
import 'settings_providers.dart';

const _backupPasswordKey = 'backup_password';

/// Settings (spec 6.6): notification times, quotes, backup, heatmap rule
/// editor v1, essential category flags.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value ?? const {};
    final repo = ref.read(settingsRepositoryProvider);

    Future<void> pickTime(String key, String fallback) async {
      final current = (settings[key] ?? fallback).split(':');
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
            hour: int.parse(current[0]), minute: int.parse(current[1])),
      );
      if (picked != null) {
        final value =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        await repo.set(key, value);
        await ref.read(notificationServiceProvider).rescheduleAll();
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Notifications'),
          ListTile(
            title: const Text('Morning quote time'),
            trailing: Text(settings['morning_time'] ?? '08:00'),
            onTap: () => pickTime('morning_time', '08:00'),
          ),
          ListTile(
            title: const Text('Evening reminder time'),
            trailing: Text(settings['evening_time'] ?? '22:00'),
            onTap: () => pickTime('evening_time', '22:00'),
          ),
          SwitchListTile(
            title: const Text('Morning quotes'),
            value: settings['quotes_enabled'] != 'false',
            onChanged: (on) async {
              await repo.set('quotes_enabled', on.toString());
              await ref.read(notificationServiceProvider).rescheduleAll();
            },
          ),
          ListTile(
            title: const Text('Quote language'),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'tr', label: Text('TR')),
                ButtonSegment(value: 'en', label: Text('EN')),
              ],
              selected: {settings['quote_lang'] ?? 'tr'},
              onSelectionChanged: (selection) async {
                await repo.set('quote_lang', selection.first);
                await ref.read(notificationServiceProvider).rescheduleAll();
              },
            ),
          ),
          const Divider(),
          const _SectionHeader('Appearance & privacy'),
          ListTile(
            title: const Text('Theme'),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'system', label: Text('Auto')),
                ButtonSegment(value: 'dark', label: Text('Dark')),
                ButtonSegment(value: 'light', label: Text('Light')),
              ],
              selected: {settings['theme_mode'] ?? 'system'},
              onSelectionChanged: (selection) =>
                  repo.set('theme_mode', selection.first),
            ),
          ),
          SwitchListTile(
            title: const Text('Block screenshots on Money pages'),
            subtitle: const Text('FLAG_SECURE, off by default'),
            value: settings['flag_secure'] == 'true',
            onChanged: (on) => repo.set('flag_secure', on.toString()),
          ),
          const Divider(),
          const _SectionHeader('Backup'),
          ListTile(
            title: const Text('Backup folder'),
            subtitle: Text(settings['backup_dir_uri'] ?? 'Not set'),
            trailing: const Icon(Icons.folder_open),
            onTap: () async {
              final dir = await FilePicker.platform.getDirectoryPath();
              if (dir != null) await repo.set('backup_dir_uri', dir);
            },
          ),
          SwitchListTile(
            title: const Text('Weekly automatic backup'),
            subtitle: const Text('Sundays 03:00, encrypted'),
            value: settings['backup_enabled'] == 'true',
            onChanged: (on) async {
              if (on && !await _ensurePassword(context)) return;
              await repo.set('backup_enabled', on.toString());
              on
                  ? await BackupScheduler.register()
                  : await BackupScheduler.cancel();
            },
          ),
          ListTile(
            title: const Text('Back up now'),
            trailing: const Icon(Icons.backup),
            onTap: () => _backupNow(context, ref, settings),
          ),
          const Divider(),
          const _SectionHeader('Money categories'),
          const _CategoryFlagsEditor(),
          const Divider(),
          const _SectionHeader('Heatmap rules'),
          const _HeatmapRuleEditor(),
        ],
      ),
    );
  }

  /// First-time password setup with the loss warning (spec 10.3).
  Future<bool> _ensurePassword(BuildContext context) async {
    const storage = FlutterSecureStorage();
    if (await storage.read(key: _backupPasswordKey) != null) return true;
    if (!context.mounted) return false;
    final password = await showDialog<String>(
      context: context,
      builder: (context) => const _BackupPasswordDialog(),
    );
    if (password == null || password.isEmpty) return false;
    await storage.write(key: _backupPasswordKey, value: password);
    return true;
  }

  Future<void> _backupNow(BuildContext context, WidgetRef ref,
      Map<String, String> settings) async {
    final messenger = ScaffoldMessenger.of(context);
    final dir = settings['backup_dir_uri'];
    if (dir == null) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Pick a backup folder first.')));
      return;
    }
    if (!await _ensurePassword(context)) return;
    const storage = FlutterSecureStorage();
    final password = await storage.read(key: _backupPasswordKey);
    if (password == null) return;
    final file = await ref
        .read(backupServiceProvider)
        .backupTo(Directory(dir), password);
    messenger.showSnackBar(
        SnackBar(content: Text('Backed up to ${file.path}')));
  }
}

class _BackupPasswordDialog extends StatefulWidget {
  const _BackupPasswordDialog();

  @override
  State<_BackupPasswordDialog> createState() => _BackupPasswordDialogState();
}

class _BackupPasswordDialogState extends State<_BackupPasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Backup password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('If you lose this password, your backups CANNOT '
              'be opened.'),
          TextField(
            controller: _controller,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}

/// is_essential / counts_in_heatmap switches (spec 6.6).
class _CategoryFlagsEditor extends ConsumerWidget {
  const _CategoryFlagsEditor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return StreamBuilder<List<MoneyCategory>>(
      stream: (db.select(db.moneyCategories)
            ..orderBy([
              (c) => OrderingTerm.asc(c.direction),
              (c) => OrderingTerm.asc(c.sortOrder),
            ]))
          .watch(),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const <MoneyCategory>[];
        return Column(
          children: [
            for (final category in rows.where((c) => c.direction == 'outcome'))
              ListTile(
                title: Text(category.name),
                subtitle: Row(
                  children: [
                    _flagChip(
                      context,
                      label: 'Essential',
                      value: category.isEssential,
                      onChanged: (v) => (db.update(db.moneyCategories)
                            ..where((c) => c.id.equals(category.id)))
                          .write(MoneyCategoriesCompanion(
                              isEssential: Value(v))),
                    ),
                    const SizedBox(width: 8),
                    _flagChip(
                      context,
                      label: 'In heatmap',
                      value: category.countsInHeatmap,
                      onChanged: (v) => (db.update(db.moneyCategories)
                            ..where((c) => c.id.equals(category.id)))
                          .write(MoneyCategoriesCompanion(
                              countsInHeatmap: Value(v))),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _flagChip(
    BuildContext context, {
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) =>
      FilterChip(
        label: Text(label),
        selected: value,
        onSelected: onChanged,
      );
}

/// Heatmap rule editor v1 (spec 6.6): per-bucket min/max/color rows.
class _HeatmapRuleEditor extends ConsumerWidget {
  const _HeatmapRuleEditor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return StreamBuilder<List<Metric>>(
      stream: (db.select(db.metrics)
            ..where((m) => m.isStarred.equals(true) & m.heatmapRule.isNotNull()))
          .watch(),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const <Metric>[];
        return Column(
          children: [
            for (final metric in rows)
              ListTile(
                title: Text(metric.title),
                trailing: const Icon(Icons.tune),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => _RuleDialog(metric: metric),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RuleDialog extends ConsumerStatefulWidget {
  const _RuleDialog({required this.metric});

  final Metric metric;

  @override
  ConsumerState<_RuleDialog> createState() => _RuleDialogState();
}

class _RuleDialogState extends ConsumerState<_RuleDialog> {
  late HeatmapRule _rule = HeatmapRule.decode(widget.metric.heatmapRule!);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.metric.title} buckets'),
      content: SizedBox(
        width: 360,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (var i = 0; i < _rule.buckets.length; i++)
              _bucketRow(i, _rule.buckets[i]),
            TextButton.icon(
              onPressed: () => setState(() {
                final last = _rule.buckets.last;
                _rule = HeatmapRule(source: _rule.source, buckets: [
                  ..._rule.buckets,
                  HeatmapBucket(
                      min: last.max ?? last.min, max: null, color: 'blue'),
                ]);
              }),
              icon: const Icon(Icons.add),
              label: const Text('Add bucket'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final db = ref.read(databaseProvider);
            await (db.update(db.metrics)
                  ..where((m) => m.id.equals(widget.metric.id)))
                .write(MetricsCompanion(
              heatmapRule: Value(_rule.encode()),
              updatedAt:
                  Value(DateTime.now().millisecondsSinceEpoch),
            ));
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _bucketRow(int index, HeatmapBucket bucket) {
    void replace(HeatmapBucket updated) => setState(() {
          final buckets = [..._rule.buckets];
          buckets[index] = updated;
          _rule = HeatmapRule(source: _rule.source, buckets: buckets);
        });

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: bucket.min.toString(),
            decoration: const InputDecoration(labelText: 'min'),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final min = double.tryParse(v);
              if (min != null) {
                replace(HeatmapBucket(
                    min: min, max: bucket.max, color: bucket.color));
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            initialValue: bucket.max?.toString() ?? '',
            decoration: const InputDecoration(labelText: 'max (empty = ∞)'),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              replace(HeatmapBucket(
                  min: bucket.min,
                  max: v.trim().isEmpty ? null : double.tryParse(v),
                  color: bucket.color));
            },
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: bucket.color,
          items: [
            for (final name in HeatColorsNames.all)
              DropdownMenuItem(value: name, child: Text(name)),
          ],
          onChanged: (color) {
            if (color != null) {
              replace(HeatmapBucket(
                  min: bucket.min, max: bucket.max, color: color));
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: _rule.buckets.length <= 1
              ? null
              : () => setState(() {
                    final buckets = [..._rule.buckets]..removeAt(index);
                    _rule =
                        HeatmapRule(source: _rule.source, buckets: buckets);
                  }),
        ),
      ],
    );
  }
}

/// Color name list for the editor dropdown.
class HeatColorsNames {
  static const all = [
    'black', 'white', 'lightBlue', 'blue', 'darkBlue',
    'lightYellow', 'yellow', 'darkYellow',
    'lightGreen', 'green', 'darkGreen',
    'orange', 'lightPink', 'pink', 'darkPink', 'red',
  ];
}
