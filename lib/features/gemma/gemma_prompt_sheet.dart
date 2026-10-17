import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_tokens.dart';
import '../settings/settings_providers.dart';
import 'gemma_page.dart';
import 'gemma_prompts.dart';

/// ✨: pick what Gemma should do (saved prompts or a one-off custom one),
/// then open the Gemma page on [noteId].
Future<void> openGemma(
  BuildContext context,
  WidgetRef ref,
  String noteId,
) async {
  final settings = await ref.read(settingsRepositoryProvider).loadAll();
  if (!context.mounted) return;
  final prompts = GemmaPrompts.load(settings);
  final picked = await showModalBottomSheet<GemmaPrompt>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _PromptSheet(prompts: prompts),
  );
  if (picked == null || !context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => GemmaPage(noteId: noteId, prompt: picked),
    ),
  );
}

class _PromptSheet extends ConsumerWidget {
  const _PromptSheet({required this.prompts});

  final List<GemmaPrompt> prompts;

  Future<void> _custom(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<(GemmaPrompt, bool)>(
      context: context,
      builder: (_) => const _CustomPromptDialog(),
    );
    if (result == null || !context.mounted) return;
    final (prompt, keep) = result;
    if (keep) {
      await GemmaPrompts.save(ref.read(settingsRepositoryProvider), [
        ...prompts,
        prompt,
      ]);
    }
    if (context.mounted) Navigator.pop(context, prompt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppTokens.accentEnd),
                const SizedBox(width: 8),
                Text('Gemma ne yapsın?', style: text.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            for (final p in prompts)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  key: Key('prompt-${p.name}'),
                  title: Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    p.prompt.split('\n').first,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(context, p),
                ),
              ),
            OutlinedButton.icon(
              key: const Key('prompt-custom'),
              icon: const Icon(Icons.edit_note),
              label: const Text('Özel komut yaz…'),
              onPressed: () => _custom(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomPromptDialog extends StatefulWidget {
  const _CustomPromptDialog();

  @override
  State<_CustomPromptDialog> createState() => _CustomPromptDialogState();
}

class _CustomPromptDialogState extends State<_CustomPromptDialog> {
  final _prompt = TextEditingController();
  final _name = TextEditingController();
  bool _keep = false;

  @override
  void dispose() {
    _prompt.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Özel komut'),
    content: SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('custom-prompt'),
            controller: _prompt,
            autofocus: true,
            minLines: 4,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'örn. Bu notu 3 maddede özetle',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 4),
          Text(
            'Not, komutun sonuna eklenir ({{not}} yazarsan oraya konur).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _keep,
            onChanged: (v) => setState(() => _keep = v ?? false),
            title: const Text('Hazır komutlara kaydet'),
          ),
          if (_keep)
            TextField(
              key: const Key('custom-prompt-name'),
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Komutun adı'),
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
        onPressed:
            _prompt.text.trim().isEmpty || (_keep && _name.text.trim().isEmpty)
            ? null
            : () => Navigator.pop(context, (
                GemmaPrompt(
                  _keep ? _name.text.trim() : 'Özel',
                  _prompt.text.trim(),
                ),
                _keep,
              )),
        child: const Text('Çalıştır'),
      ),
    ],
  );
}
