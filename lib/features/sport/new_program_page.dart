import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/sport_repository.dart';
import '../../theme/glow_background.dart';
import 'sport_providers.dart';

/// New Program authoring (CR-3 §6.1/§6.2): name + exercise blocks, with
/// name autocomplete, set/duration validation, and superset grouping via
/// long-press multi-select.
class NewProgramPage extends ConsumerStatefulWidget {
  const NewProgramPage({super.key});

  @override
  ConsumerState<NewProgramPage> createState() => _NewProgramPageState();
}

class _NewProgramPageState extends ConsumerState<NewProgramPage> {
  final _name = TextEditingController();
  final List<ExerciseDraft> _blocks = [ExerciseDraft(name: '')];

  /// Indices selected in superset mode; empty = normal mode.
  final Set<int> _selected = {};
  int _nextSupersetGroup = 1;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _selecting => _selected.isNotEmpty;

  bool get _canSave =>
      _name.text.trim().isNotEmpty && _blocks.any((b) => b.isValid);

  @override
  Widget build(BuildContext context) {
    final titles = ref.watch(exerciseTitlesProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('New program'),
        actions: [
          if (_selecting)
            TextButton(onPressed: _makeSuperset, child: const Text('Superset')),
        ],
      ),
      body: GlowBackground(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Program name'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < _blocks.length; i++)
              _ExerciseBlockCard(
                key: ValueKey('block-$i'),
                index: i,
                draft: _blocks[i],
                titles: titles,
                selected: _selected.contains(i),
                selecting: _selecting,
                onChanged: () => setState(() {}),
                onLongPress: () => setState(() => _selected.add(i)),
                onToggleSelect: () => setState(() {
                  _selected.contains(i)
                      ? _selected.remove(i)
                      : _selected.add(i);
                }),
                onRemove: _blocks.length == 1
                    ? null
                    : () => setState(() => _blocks.removeAt(i)),
              ),
            TextButton.icon(
              onPressed: () =>
                  setState(() => _blocks.add(ExerciseDraft(name: ''))),
              icon: const Icon(Icons.add),
              label: const Text('Add exercise block'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _canSave ? _save : null,
              child: const Text('Save program'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeSuperset() async {
    if (_selected.length < 2) {
      setState(() => _selected.clear());
      return;
    }
    final rounds = await showDialog<int>(
      context: context,
      builder: (context) => const _SupersetRoundsDialog(),
    );
    if (rounds == null) return;
    final group = _nextSupersetGroup++;
    for (final i in _selected) {
      _blocks[i].supersetGroup = group;
      _blocks[i].supersetRounds = rounds;
    }
    setState(() => _selected.clear());
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    await ref
        .read(sportRepositoryProvider)
        .saveProgram(name: _name.text, blocks: _blocks);
    navigator.pop();
  }
}

class _ExerciseBlockCard extends StatelessWidget {
  const _ExerciseBlockCard({
    super.key,
    required this.index,
    required this.draft,
    required this.titles,
    required this.selected,
    required this.selecting,
    required this.onChanged,
    required this.onLongPress,
    required this.onToggleSelect,
    required this.onRemove,
  });

  final int index;
  final ExerciseDraft draft;
  final List<String> titles;
  final bool selected;
  final bool selecting;
  final VoidCallback onChanged;
  final VoidCallback onLongPress;
  final VoidCallback onToggleSelect;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.18)
          : null,
      child: InkWell(
        onLongPress: onLongPress,
        onTap: selecting ? onToggleSelect : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Autocomplete<String>(
                      key: ValueKey('block-name-$index'),
                      initialValue: TextEditingValue(text: draft.name),
                      optionsBuilder: (value) {
                        if (value.text.isEmpty) return titles;
                        return titles.where(
                          (t) => t.toLowerCase().contains(
                            value.text.toLowerCase(),
                          ),
                        );
                      },
                      onSelected: (v) {
                        draft.name = v;
                        onChanged();
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onSubmit) {
                            controller.text = draft.name;
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Exercise name',
                              ),
                              onChanged: (v) {
                                draft.name = v;
                                onChanged();
                              },
                            );
                          },
                    ),
                  ),
                  if (onRemove != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onRemove,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: ValueKey('block-sets-$index'),
                      decoration: const InputDecoration(
                        labelText: 'Sets (e.g. 15x3)',
                      ),
                      onChanged: (v) {
                        draft.sets = v;
                        onChanged();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      key: ValueKey('block-duration-$index'),
                      decoration: const InputDecoration(labelText: 'Duration'),
                      onChanged: (v) {
                        draft.duration = v;
                        onChanged();
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (draft.supersetGroup != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, right: 8),
                      child: Chip(
                        label: Text(
                          'Superset ${draft.supersetGroup} '
                          '×${draft.supersetRounds}',
                        ),
                      ),
                    ),
                  const Spacer(),
                  Row(
                    children: [
                      const Text('Rest after'),
                      Switch(
                        value: draft.restAfter,
                        onChanged: (v) {
                          draft.restAfter = v;
                          onChanged();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupersetRoundsDialog extends StatefulWidget {
  const _SupersetRoundsDialog();

  @override
  State<_SupersetRoundsDialog> createState() => _SupersetRoundsDialogState();
}

class _SupersetRoundsDialogState extends State<_SupersetRoundsDialog> {
  final _controller = TextEditingController(text: '3');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Superset'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'How many rounds together?',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, int.tryParse(_controller.text) ?? 1),
          child: const Text('Group'),
        ),
      ],
    );
  }
}
