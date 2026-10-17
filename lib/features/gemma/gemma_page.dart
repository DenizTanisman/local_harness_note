import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/selection_menu.dart';
import '../../data/db/app_database.dart';
import '../../theme/app_tokens.dart';
import '../notes/notes_providers.dart';
import 'gemma_prompts.dart';
import 'gemma_service.dart';

/// ✨ flow (spec §5): Gemma runs the saved prompt on the note, the answer
/// streams into an editable field, "Onayla" replaces the note (the old
/// text is kept as a version). Leaving while Gemma runs, or with an answer
/// not yet accepted, asks first.
class GemmaPage extends ConsumerStatefulWidget {
  const GemmaPage({
    super.key,
    required this.noteId,
    this.prompt = GemmaPrompts.tidy,
  });

  final String noteId;

  /// What Gemma is asked to do (picked on ✨; "Toparla" by default).
  final GemmaPrompt prompt;

  @override
  ConsumerState<GemmaPage> createState() => _GemmaPageState();
}

class _GemmaPageState extends ConsumerState<GemmaPage> {
  final _output = TextEditingController();
  final _outputFocus = FocusNode();
  late final _selectionMenu = SelectionMenuOnRange(_output, _outputFocus);
  Note? _note;
  bool _running = false;
  bool _accepted = false;
  String? _error;
  StreamSubscription<String>? _sub;
  bool _showOriginal = false;

  // Read once: dispose() still needs it to stop a running generation.
  late final GemmaService _gemma = ref.read(gemmaServiceProvider);

  bool get _guarded =>
      !_accepted && (_running || _output.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    _selectionMenu; // start listening
    _start();
  }

  Future<void> _start() async {
    _note = await ref.read(notesRepositoryProvider).getNote(widget.noteId);
    if (!mounted) return;
    setState(() {});
    await _gemma.refresh();
    if (_gemma.status.value is GemmaReady) _generate();
  }

  Future<void> _generate() async {
    final note = _note;
    if (note == null) return;
    final prompt = GemmaService.buildPrompt(widget.prompt.prompt, note.body);
    await _sub?.cancel();
    setState(() {
      _output.clear();
      _error = null;
      _running = true;
    });
    _sub = _gemma
        .generate(prompt)
        .listen(
          (token) {
            if (!mounted) return;
            _output.text += token;
            setState(() {});
          },
          onError: (Object e) {
            if (mounted) {
              setState(() {
                _running = false;
                _error = '$e';
              });
            }
          },
          onDone: () {
            if (mounted) {
              setState(() {
                _running = false;
                _output.text = _output.text.trim();
              });
            }
          },
          cancelOnError: true,
        );
  }

  Future<void> _stop() async {
    await _gemma.stop();
    if (mounted) setState(() => _running = false);
  }

  Future<void> _accept() async {
    final text = _output.text.trim();
    if (text.isEmpty) return;
    final saved = await ref
        .read(notesRepositoryProvider)
        .replaceBody(widget.noteId, text, reason: 'gemma');
    if (!mounted) return;
    if (!saved) {
      setState(
        () => _error =
            'Bu not artık yok (silinmiş ya da birleştirme geri '
            'alınmış). Metni kopyalayıp yeni bir nota yapıştırabilirsin.',
      );
      return;
    }
    _accepted = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Not güncellendi · eski hali Sürümler’de')),
    );
    Navigator.of(context).pop(true);
  }

  Future<bool> _confirmLeave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emin misin?'),
        content: Text(
          _running
              ? 'Gemma hâlâ çalışıyor. Çıkarsan çıktı kaybolacak.'
              : 'Çıktıyı onaylamadın. Çıkarsan kaybolacak.',
        ),
        actions: [
          FilledButton(
            key: const Key('gemma-stay'),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kal'),
          ),
          TextButton(
            key: const Key('gemma-leave'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çık'),
          ),
        ],
      ),
    );
    return leave == true;
  }

  Future<void> _leave() async {
    if (_guarded && !await _confirmLeave()) return;
    if (_running) await _gemma.stop();
    _accepted = true; // let the pop through
    if (mounted) Navigator.of(context).pop(false);
  }

  @override
  void dispose() {
    _sub?.cancel();
    if (_running) _gemma.stop();
    _selectionMenu.dispose();
    _outputFocus.dispose();
    _output.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_guarded,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Vazgeç',
            onPressed: _leave,
          ),
          title: Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppTokens.accentEnd),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Gemma · ${widget.prompt.name}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: ValueListenableBuilder<GemmaStatus>(
          valueListenable: _gemma.status,
          builder: (context, status, _) => switch (status) {
            GemmaReady() => _body(),
            GemmaDownloading(:final percent) => _ModelMessage(
              text: 'Gemma indiriliyor… %$percent',
              progress: percent / 100,
              action: TextButton(
                onPressed: _gemma.cancelDownload,
                child: const Text('İptal'),
              ),
            ),
            GemmaNotInstalled() || GemmaFailed() => _ModelMessage(
              text: status is GemmaFailed
                  ? status.message
                  : 'Gemma modeli bu telefonda yok. Bir kez indirilir '
                        '(${GemmaService.modelSizeLabel}), sonra internetsiz '
                        'çalışır. Wi-Fi önerilir.',
              action: FilledButton.icon(
                key: const Key('gemma-download'),
                icon: const Icon(Icons.download),
                label: const Text('Modeli indir'),
                onPressed: () async {
                  await _gemma.download();
                  if (mounted && _gemma.status.value is GemmaReady) {
                    _generate();
                  }
                },
              ),
            ),
            GemmaUnknown() => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }

  Widget _body() {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _showOriginal = !_showOriginal),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                children: [
                  Text('Orijinal not', style: theme.textTheme.labelLarge),
                  Icon(_showOriginal ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_showOriginal)
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTokens.surfaceCard,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _note?.body ?? '',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text(
                  _running ? 'Gemma yazıyor…' : 'Çıktı (düzenleyebilirsin)',
                  style: theme.textTheme.labelLarge,
                ),
                if (_running) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTokens.danger,
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                key: const Key('gemma-output'),
                controller: _output,
                focusNode: _outputFocus,
                readOnly: _running,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_running)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.stop),
                      label: const Text('Durdur'),
                      onPressed: _stop,
                    ),
                  )
                else ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('gemma-retry'),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Yeniden üret'),
                      onPressed: _generate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('gemma-accept'),
                      icon: const Icon(Icons.check),
                      label: const Text('Onayla'),
                      onPressed: _output.text.trim().isEmpty ? null : _accept,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelMessage extends StatelessWidget {
  const _ModelMessage({required this.text, this.progress, this.action});

  final String text;
  final double? progress;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 40, color: AppTokens.accentEnd),
          const SizedBox(height: 16),
          Text(text, textAlign: TextAlign.center),
          if (progress != null) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: progress),
          ],
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    ),
  );
}
