import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/note_text.dart';
import '../../theme/app_tokens.dart';
import '../notes/notes_providers.dart';
import '../notes/tag_suggestion_bar.dart';

/// Inside the quick-note bubble: type, `#` suggestions, Kaydet — the field
/// clears for the next note. Collapsing the bubble with text in the field
/// saves it, so nothing typed is lost.
class QuickNotePage extends ConsumerStatefulWidget {
  const QuickNotePage({super.key});

  @override
  ConsumerState<QuickNotePage> createState() => _QuickNotePageState();
}

class _QuickNotePageState extends ConsumerState<QuickNotePage>
    with WidgetsBindingObserver {
  final _text = TextEditingController();
  final _focus = FocusNode();
  String? _lastSaved;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _text.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _showKeyboard());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _save(); // bubble collapsed or dismissed
    } else if (state == AppLifecycleState.resumed) {
      _showKeyboard();
    }
  }

  void _showKeyboard() {
    if (!mounted) return;
    _focus.requestFocus();
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _focus.hasFocus) {
        SystemChannels.textInput.invokeMethod<void>('TextInput.show');
      }
    });
  }

  static const _bubble = MethodChannel('local_harness_not/bubble');

  /// Saves the text. With [collapse], confirms with a toast and folds the
  /// bubble, back to the app the user was in.
  Future<void> _save({bool collapse = false}) async {
    final body = _text.text.trim();
    if (body.isEmpty || _saving) return;
    _saving = true;
    try {
      await ref.read(notesRepositoryProvider).create(body, source: 'bubble');
      _text.clear();
      final title = NoteText.title(body, max: 40);
      if (mounted) setState(() => _lastSaved = title);
      if (collapse) {
        try {
          await _bubble.invokeMethod<void>('savedAndCollapse', title);
        } on MissingPluginException {
          // Not running inside the bubble (tests).
        }
      }
    } finally {
      _saving = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: AppTokens.accentEnd, size: 20),
                  const SizedBox(width: 6),
                  Text('Hızlı not', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  FilledButton.icon(
                    key: const Key('quick-save'),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Kaydet'),
                    onPressed: _text.text.trim().isEmpty
                        ? null
                        : () => _save(collapse: true),
                  ),
                ],
              ),
            ),
            if (_lastSaved != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Text(
                  '✓ Kaydedildi: $_lastSaved',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTokens.textAccent,
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  key: const Key('quick-text'),
                  controller: _text,
                  focusNode: _focus,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  textAlignVertical: TextAlignVertical.top,
                  style: theme.textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'Aklındakini yaz…  (#etiket)',
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            TagSuggestionBar(controller: _text, focusNode: _focus),
          ],
        ),
      ),
    );
  }
}
