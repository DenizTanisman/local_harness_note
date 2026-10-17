import 'package:flutter/material.dart';

import '../../core/note_links.dart';
import '../../theme/app_tokens.dart';
import 'note_body_view.dart';

/// Shown above the keyboard while the cursor is on a link: open it in its
/// app, or give it a short phrase to show instead of the URL.
class LinkActionBar extends StatefulWidget {
  const LinkActionBar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// Called after the text was changed (e.g. to schedule a save).
  final VoidCallback? onChanged;

  @override
  State<LinkActionBar> createState() => _LinkActionBarState();
}

class _LinkActionBarState extends State<LinkActionBar> {
  NoteLink? _link;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
    widget.focusNode.addListener(_update);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    widget.focusNode.removeListener(_update);
    super.dispose();
  }

  void _update() {
    final selection = widget.controller.selection;
    final next = widget.focusNode.hasFocus && selection.isCollapsed
        ? NoteLinks.at(widget.controller.text, selection.baseOffset)
        : null;
    if (!mounted) return;
    if (next?.start == _link?.start &&
        next?.end == _link?.end &&
        next?.label == _link?.label) {
      return;
    }
    setState(() => _link = next);
  }

  Future<void> _label(NoteLink link) async {
    final label = await showDialog<String>(
      context: context,
      builder: (_) => _LabelDialog(link: link),
    );
    if (label == null) return;
    final c = widget.controller;
    final text = NoteLinks.setLabel(c.text, link, label);
    final end = link.end + (text.length - c.text.length);
    c.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: end.clamp(0, text.length)),
    );
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final link = _link;
    if (link == null) return const SizedBox.shrink();
    return Container(
      key: const Key('link-actions'),
      height: 52,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTokens.surfaceCardBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ActionChip(
              avatar: const Icon(Icons.open_in_new, size: 16),
              label: Text(
                link.display,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () => openNoteLink(context, link),
            ),
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Icon(Icons.short_text, size: 16),
            label: Text(link.label == null ? 'Kısa ad ver' : 'Adı değiştir'),
            onPressed: () => _label(link),
          ),
        ],
      ),
    );
  }
}

class _LabelDialog extends StatefulWidget {
  const _LabelDialog({required this.link});

  final NoteLink link;

  @override
  State<_LabelDialog> createState() => _LabelDialogState();
}

class _LabelDialogState extends State<_LabelDialog> {
  late final _controller = TextEditingController(text: widget.link.label);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Linke kısa ad ver'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          NoteLinks.shortUrl(widget.link.url, max: 48),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('link-label'),
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'örn. Konuşma videosu'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
      ],
    ),
    actions: [
      if (widget.link.label != null)
        TextButton(
          onPressed: () => Navigator.pop(context, ''),
          child: const Text('Adı kaldır'),
        ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Vazgeç'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('Kaydet'),
      ),
    ],
  );
}
