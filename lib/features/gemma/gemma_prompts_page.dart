import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/settings_providers.dart';
import 'gemma_prompts.dart';
import 'gemma_service.dart';

/// Ayarlar › Gemma komutları: the prompts ✨ offers — edit, add, delete,
/// reorder by long-press drag, or go back to the two defaults.
class GemmaPromptsPage extends ConsumerWidget {
  const GemmaPromptsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value ?? const {};
    final prompts = GemmaPrompts.load(settings);
    final repo = ref.read(settingsRepositoryProvider);

    Future<void> edit([int? index]) async {
      final result = await showDialog<GemmaPrompt>(
        context: context,
        builder: (_) =>
            _EditDialog(initial: index == null ? null : prompts[index]),
      );
      if (result == null) return;
      final next = [...prompts];
      index == null ? next.add(result) : next[index] = result;
      await GemmaPrompts.save(repo, next);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemma komutları'),
        actions: [
          TextButton(
            onPressed: () => GemmaPrompts.save(repo, GemmaPrompts.defaults),
            child: const Text('Varsayılanlar'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: edit,
        icon: const Icon(Icons.add),
        label: const Text('Yeni komut'),
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
        itemCount: prompts.length,
        onReorderItem: (from, to) {
          final next = [...prompts];
          next.insert(to, next.removeAt(from));
          GemmaPrompts.save(repo, next);
        },
        itemBuilder: (context, i) => Card(
          key: ValueKey('${prompts[i].name}$i'),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(
              prompts[i].name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              prompts[i].prompt,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => edit(i),
            trailing: prompts.length <= 1
                ? null
                : IconButton(
                    tooltip: 'Sil',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        GemmaPrompts.save(repo, [...prompts]..removeAt(i)),
                  ),
          ),
        ),
      ),
    );
  }
}

class _EditDialog extends StatefulWidget {
  const _EditDialog({this.initial});

  final GemmaPrompt? initial;

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _prompt = TextEditingController(text: widget.initial?.prompt);

  @override
  void dispose() {
    _name.dispose();
    _prompt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.initial == null ? 'Yeni komut' : 'Komutu düzenle'),
    content: SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Adı'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Text(
            '${GemmaService.noteSlot} yerine notun metni konur '
            '(yoksa sona eklenir).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _prompt,
            minLines: 6,
            maxLines: 12,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Vazgeç'),
      ),
      FilledButton(
        onPressed: _name.text.trim().isEmpty || _prompt.text.trim().isEmpty
            ? null
            : () => Navigator.pop(
                context,
                GemmaPrompt(_name.text.trim(), _prompt.text.trim()),
              ),
        child: const Text('Kaydet'),
      ),
    ],
  );
}
