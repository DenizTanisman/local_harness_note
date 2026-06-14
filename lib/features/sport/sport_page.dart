import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_key.dart';
import '../../data/db/app_database.dart';
import '../../theme/app_tokens.dart';
import '../../theme/glow_background.dart';
import '../health/health_providers.dart';
import '../shared/continuous_sparkline.dart';
import '../shared/period_bar.dart';
import 'new_program_page.dart';
import 'sport_providers.dart';
import '../settings/settings_button.dart';

/// Sport tab (CR-3 §6): programs list + calorie entry. The Programs and
/// calorie sparklines arrive in CR3-P6.
class SportPage extends ConsumerWidget {
  const SportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programs = ref.watch(programsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sport'),
        actions: const [SettingsButton()],
      ),
      body: GlowBackground(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // Unified month selector (CR-3 follow-up #5).
            Consumer(
              builder: (context, ref, _) {
                final month = ref.watch(sportMonthProvider);
                return PeriodBar(
                  label: month,
                  highlighted: month != dateKey(DateTime.now()).substring(0, 7),
                  resetLabel: 'This month',
                  onReset: () => ref.read(sportMonthProvider.notifier).reset(),
                  onPrev: () => ref.read(sportMonthProvider.notifier).shift(-1),
                  onNext: () => ref.read(sportMonthProvider.notifier).shift(1),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Programs',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NewProgramPage()),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('ADD'),
                  ),
                ],
              ),
            ),
            programs.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: $e'),
              ),
              data: (rows) => rows.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('No programs yet — tap ADD to build one.'),
                    )
                  : Column(
                      children: [
                        for (final p in rows) _ProgramTile(program: p),
                      ],
                    ),
            ),
            const _ProgramsSparkline(),
            const _CalorieSparkline(),
            const Divider(height: 32),
            const _CalorieEntryCard(),
          ],
        ),
      ),
    );
  }
}

/// Programs sparkline (CR-3 §6/§11): daily volume; tap a height to see
/// which program it was.
class _ProgramsSparkline extends ConsumerWidget {
  const _ProgramsSparkline();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(sportMonthProvider);
    final data = ref.watch(programMonthProvider).value ?? const {};
    if (data.isEmpty) return const SizedBox.shrink();
    final programs = ref.watch(programsProvider).value ?? const [];
    final nameById = {for (final p in programs) p.id: p.name};
    final parts = month.split('-').map(int.parse).toList();
    final days = DateTime(parts[0], parts[1] + 1, 0).day;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Programs', style: Theme.of(context).textTheme.bodySmall),
          ContinuousSparkline(
            key: const ValueKey('programs-sparkline'),
            daysInMonth: days,
            values: {for (final e in data.entries) e.key: e.value.volume},
            selectedDay: 1,
            onDayTap: (day) {
              final entry = data[day];
              final name = entry == null
                  ? null
                  : (nameById[entry.programId] ?? 'program');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    name == null ? 'No program on day $day' : 'Day $day: $name',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Calorie sparkline (CR-3 §6/§11): daily intake with the FROZEN per-day
/// color (green/yellow/red).
class _CalorieSparkline extends ConsumerWidget {
  const _CalorieSparkline();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(sportMonthProvider);
    final data = ref.watch(calorieMonthProvider).value ?? const {};
    if (data.isEmpty) return const SizedBox.shrink();
    final parts = month.split('-').map(int.parse).toList();
    final days = DateTime(parts[0], parts[1] + 1, 0).day;
    Color colorFor(String? name) => switch (name) {
      'red' => AppTokens.moneyRed,
      'yellow' => AppTokens.warn,
      'green' => AppTokens.moneyGreen,
      _ => AppTokens.sparkline,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calories', style: Theme.of(context).textTheme.bodySmall),
          ContinuousSparkline(
            key: const ValueKey('calorie-sparkline'),
            daysInMonth: days,
            values: {for (final e in data.entries) e.key: e.value.intake},
            // Per-day frozen colors (index 0 unused; 1..N).
            dayColors: [
              AppTokens.sparkline,
              for (var d = 1; d <= days; d++) colorFor(data[d]?.color),
            ],
            selectedDay: 1,
          ),
        ],
      ),
    );
  }
}

class _ProgramTile extends ConsumerWidget {
  const _ProgramTile({required this.program});

  final Program program;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(_exercisesProvider(program.id));
    return ExpansionTile(
      title: Text(program.name),
      children: [
        exercises.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Text('Error: $e'),
          data: (rows) => Column(
            children: [
              for (final ex in rows)
                ListTile(
                  dense: true,
                  title: Text(ex.name),
                  subtitle: Text(
                    [
                      if (ex.sets != null) 'Sets ${ex.sets}',
                      if (ex.duration != null) 'Duration ${ex.duration}',
                      if (ex.supersetGroup != null)
                        'Superset ${ex.supersetGroup} ×${ex.supersetRounds}',
                      if (ex.restAfter) 'Rest after',
                    ].join('  ·  '),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => ref
                        .read(sportRepositoryProvider)
                        .logProgram(
                          date: dateKey(DateTime.now()),
                          programId: program.id,
                          volume: rows.length.toDouble(),
                        ),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Log today'),
                  ),
                  TextButton.icon(
                    onPressed: () => ref
                        .read(sportRepositoryProvider)
                        .deleteProgram(program.id),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final _exercisesProvider = StreamProvider.family<List<ProgramExercise>, int>((
  ref,
  programId,
) {
  return ref.watch(sportRepositoryProvider).watchExercises(programId);
});

class _CalorieEntryCard extends ConsumerStatefulWidget {
  const _CalorieEntryCard();

  @override
  ConsumerState<_CalorieEntryCard> createState() => _CalorieEntryCardState();
}

class _CalorieEntryCardState extends ConsumerState<_CalorieEntryCard> {
  final _name = TextEditingController();
  final _cal = TextEditingController(); // calories for ONE item/portion
  final _qty = TextEditingController(text: '1'); // ×N
  String _meal = 'breakfast';
  String? _category; // selected category chip (filters + tags new foods)

  @override
  void dispose() {
    _name.dispose();
    _cal.dispose();
    _qty.dispose();
    super.dispose();
  }

  double? get _perUnit => double.tryParse(_cal.text);
  int get _quantity => int.tryParse(_qty.text) ?? 0;
  bool get _canAdd =>
      _name.text.trim().isNotEmpty && (_perUnit ?? -1) >= 0 && _quantity >= 1;

  /// Tap a saved food → its name + per-unit calories fill the top row; the
  /// user just sets ×N and saves.
  void _pickFood(SavedFoodType food) {
    setState(() {
      _name.text = food.name;
      _cal.text = food.kcalPerUnit == null ? '' : _kcalText(food.kcalPerUnit!);
      _category = food.category ?? _category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foods = ref.watch(foodsProvider).value ?? const [];
    final entries = ref.watch(calorieEntriesTodayProvider).value ?? const [];
    final total = entries.fold<double>(0, (a, e) => a + e.kcal);
    final inCategory = _category == null
        ? const <SavedFoodType>[]
        : foods.where((f) => f.category == _category).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Calorie intake', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            // Name + per-item calories + ×N quantity.
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    key: const ValueKey('calorie-name'),
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    key: const ValueKey('calorie-cal'),
                    controller: _cal,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'cal',
                      suffixText: '/ea',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 14),
                  child: Text('×'),
                ),
                SizedBox(
                  width: 40,
                  child: TextField(
                    key: const ValueKey('calorie-qty'),
                    controller: _qty,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Category chips — tap to browse previously saved foods under it.
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final c in calorieCategories)
                  ChoiceChip(
                    label: Text(c),
                    selected: _category == c,
                    onSelected: (_) =>
                        setState(() => _category = _category == c ? null : c),
                  ),
              ],
            ),
            if (_category != null) ...[
              const SizedBox(height: 6),
              if (inCategory.isEmpty)
                Text(
                  'No saved $_category foods yet — type a name + cal to add one.',
                  style: theme.textTheme.bodySmall,
                )
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final f in inCategory)
                      ActionChip(
                        label: Text(
                          f.kcalPerUnit == null
                              ? f.name
                              : '${f.name} · ${_kcalText(f.kcalPerUnit!)}',
                        ),
                        onPressed: () => _pickFood(f),
                      ),
                  ],
                ),
            ],
            const SizedBox(height: 10),
            // Meal time.
            Wrap(
              spacing: 6,
              children: [
                for (final m in const ['breakfast', 'lunch', 'dinner'])
                  ChoiceChip(
                    label: Text('${m[0].toUpperCase()}${m.substring(1)}'),
                    selected: _meal == m,
                    onSelected: (_) => setState(() => _meal = m),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton(
              key: const ValueKey('calorie-save'),
              onPressed: _canAdd ? _add : null,
              child: Text(
                _canAdd && _quantity >= 1
                    ? 'Save (${_kcalText((_perUnit ?? 0) * _quantity)} kcal)'
                    : 'Save',
              ),
            ),
            if (entries.isNotEmpty) ...[
              const Divider(),
              for (final e in entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.quantity > 1 ? '${e.type} ×${e.quantity}' : e.type,
                        ),
                      ),
                      Text(
                        '${_kcalText(e.kcal)} kcal',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Today: ${total.toStringAsFixed(0)} kcal',
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _add() async {
    // The frozen target snapshot (§11) is today's live TDEE_static.
    final target = ref.read(bodyStatsProvider).tdeeStatic;
    final perUnit = _perUnit!;
    final qty = _quantity;
    await ref
        .read(sportRepositoryProvider)
        .addCalorieEntry(
          date: dateKey(DateTime.now()),
          meal: _meal,
          kcal: perUnit * qty, // total
          type: _name.text.trim(),
          quantity: qty,
          category: _category,
          kcalPerUnit: perUnit,
          currentTarget: target,
        );
    _name.clear();
    _cal.clear();
    _qty.text = '1';
    setState(() {});
  }
}

/// '20' not '20.0'; keeps one decimal only when fractional.
String _kcalText(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toString();
