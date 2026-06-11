import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home_providers.dart';

/// ADD bottom sheet (spec 6.2): title + input type; option rows for checkbox.
class AddMetricSheet extends ConsumerStatefulWidget {
  const AddMetricSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddMetricSheet(),
    );
  }

  @override
  ConsumerState<AddMetricSheet> createState() => _AddMetricSheetState();
}

class _AddMetricSheetState extends ConsumerState<AddMetricSheet> {
  final _title = TextEditingController();
  final List<TextEditingController> _options = [];
  String _inputType = 'int';

  @override
  void dispose() {
    _title.dispose();
    for (final c in _options) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid {
    if (_title.text.trim().isEmpty) return false;
    if (_inputType == 'checkbox' &&
        !_options.any((c) => c.text.trim().isNotEmpty)) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New metric', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'int', label: Text('Number')),
              ButtonSegment(value: 'text', label: Text('Text')),
              ButtonSegment(value: 'checkbox', label: Text('Checkbox')),
            ],
            selected: {_inputType},
            onSelectionChanged: (selection) {
              setState(() {
                _inputType = selection.first;
                if (_inputType == 'checkbox' && _options.isEmpty) {
                  _options.add(TextEditingController());
                }
              });
            },
          ),
          if (_inputType == 'checkbox') ...[
            const SizedBox(height: 8),
            for (var i = 0; i < _options.length; i++)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: _options[i],
                  decoration: InputDecoration(
                    labelText: 'Option ${i + 1}',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            TextButton.icon(
              onPressed: () =>
                  setState(() => _options.add(TextEditingController())),
              icon: const Icon(Icons.add),
              label: const Text('Add option'),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _valid ? _save : null,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    await ref.read(entryRepositoryProvider).addMetric(
          title: _title.text.trim(),
          inputType: _inputType,
          options: _inputType == 'checkbox'
              ? [
                  for (final c in _options)
                    if (c.text.trim().isNotEmpty) c.text.trim(),
                ]
              : const [],
        );
    navigator.pop();
  }
}
