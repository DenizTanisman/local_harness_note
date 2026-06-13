import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_key.dart';
import '../../data/db/app_database.dart';
import '../../theme/glow_background.dart';
import 'new_program_page.dart';
import 'sport_providers.dart';

/// Sport tab (CR-3 §6): programs list + calorie entry. The Programs and
/// calorie sparklines arrive in CR3-P6.
class SportPage extends ConsumerWidget {
  const SportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programs = ref.watch(programsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sport')),
      body: GlowBackground(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
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
            const Divider(height: 32),
            const _CalorieEntryCard(),
          ],
        ),
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => ref
                      .read(sportRepositoryProvider)
                      .deleteProgram(program.id),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                ),
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
  final _kcal = TextEditingController();
  String _meal = 'breakfast';
  String? _type;

  @override
  void dispose() {
    _kcal.dispose();
    super.dispose();
  }

  bool get _canAdd => _type != null && (double.tryParse(_kcal.text) ?? -1) >= 0;

  @override
  Widget build(BuildContext context) {
    final types = ref.watch(foodTypesProvider).value ?? const [];
    _type ??= types.isNotEmpty ? types.first : null;
    final entries = ref.watch(calorieEntriesTodayProvider).value ?? const [];
    final total = entries.fold<double>(0, (a, e) => a + e.kcal);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Calorie intake',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _meal,
              decoration: const InputDecoration(labelText: 'Meal'),
              items: const [
                DropdownMenuItem(value: 'breakfast', child: Text('Breakfast')),
                DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
                DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
              ],
              onChanged: (v) => setState(() => _meal = v ?? 'breakfast'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kcal,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Calories',
                      suffixText: 'kcal',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: const ValueKey('food-type'),
                          initialValue: types.contains(_type) ? _type : null,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Type'),
                          items: [
                            for (final t in types)
                              DropdownMenuItem(value: t, child: Text(t)),
                          ],
                          onChanged: (v) => setState(() => _type = v),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        tooltip: 'New type',
                        onPressed: _newType,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _canAdd ? _add : null,
              child: const Text('Add'),
            ),
            if (entries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Today: ${total.toStringAsFixed(0)} kcal'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _newType() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _NewTypeDialog(),
    );
    if (name != null && name.trim().isNotEmpty) {
      await ref.read(sportRepositoryProvider).addFoodType(name);
      setState(() => _type = name.trim());
    }
  }

  Future<void> _add() async {
    await ref
        .read(sportRepositoryProvider)
        .addCalorieEntry(
          date: dateKey(DateTime.now()),
          meal: _meal,
          kcal: double.parse(_kcal.text),
          type: _type!,
        );
    _kcal.clear();
    setState(() {});
  }
}

class _NewTypeDialog extends StatefulWidget {
  const _NewTypeDialog();

  @override
  State<_NewTypeDialog> createState() => _NewTypeDialogState();
}

class _NewTypeDialogState extends State<_NewTypeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New food type'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
