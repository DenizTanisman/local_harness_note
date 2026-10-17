import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/note_text.dart';
import '../../core/tag_categories.dart';
import '../../theme/app_tokens.dart';
import 'category_icon.dart';
import 'notes_providers.dart';

/// Existing `#tags` for the hashtag being typed in [controller], most used
/// first, narrowed as you type (Turkish-insensitive). Tapping one completes
/// it. Renders nothing when the cursor is not in a hashtag. Used by the
/// note editor and the quick-note bubble.
class TagSuggestionBar extends ConsumerStatefulWidget {
  const TagSuggestionBar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// Called after a tag was inserted (e.g. to schedule a save).
  final VoidCallback? onChanged;

  @override
  ConsumerState<TagSuggestionBar> createState() => _TagSuggestionBarState();
}

class _TagSuggestionBarState extends ConsumerState<TagSuggestionBar> {
  StreamSubscription<List<({String tag, int count})>>? _watch;
  List<({String tag, int count})> _counts = const [];
  List<String> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
    widget.focusNode.addListener(_update);
    _watch = ref.read(notesRepositoryProvider).watchTagCounts().listen((c) {
      _counts = c;
      _update();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    widget.focusNode.removeListener(_update);
    _watch?.cancel();
    super.dispose();
  }

  void _update() {
    final at = widget.focusNode.hasFocus
        ? NoteText.tagAt(
            widget.controller.text,
            widget.controller.selection.baseOffset,
          )
        : null;
    final used = [for (final c in _counts) c.tag];
    final next = at == null
        ? const <String>[]
        : NoteText.suggestTags(
            [
              ...used,
              // Ready-made categories the user has not used yet, after the
              // ones in use (main tags only).
              for (final c in TagCategories.all)
                if (!used.any(
                  (u) =>
                      NoteText.fold(u.split('-').first) == NoteText.fold(c.tag),
                ))
                  c.tag,
            ],
            at.prefix,
            limit: 20,
          );
    if (!mounted || listEquals(next, _suggestions)) return;
    setState(() => _suggestions = next);
  }

  void _pick(String tag) {
    final c = widget.controller;
    final at = NoteText.tagAt(c.text, c.selection.baseOffset);
    if (at == null) return;
    final result = NoteText.insertTag(c.text, at, tag);
    c.value = TextEditingValue(
      text: result.text,
      selection: TextSelection.collapsed(offset: result.cursor),
    );
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_suggestions.isEmpty) return const SizedBox.shrink();
    final counts = {for (final c in _counts) c.tag: c.count};
    return Container(
      key: const Key('tag-suggestions'),
      height: 52,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTokens.surfaceCardBorder)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          for (final tag in _suggestions)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ActionChip(
                avatar: tag.contains('-')
                    ? null
                    : CategoryIcon(tag: tag, size: 22),
                label: Text(
                  counts[tag] == null ? '#$tag' : '#$tag  ${counts[tag]}',
                ),
                onPressed: () => _pick(tag),
              ),
            ),
        ],
      ),
    );
  }
}
