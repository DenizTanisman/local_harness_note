import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/note_links.dart';
import '../../core/note_text.dart';
import '../../data/repositories/notes_repository.dart';
import '../../theme/app_tokens.dart';
import 'note_editor_page.dart';
import 'notes_providers.dart';

/// Every note with a tag (sub-tags included), last edited first, opened by
/// tapping the tag in a note. Each other note has "Birleştir": the picked
/// ones and the note this page came from become one new note under the
/// tag; the originals go to the archive (Geri al, or restore from there).
/// Pops with the merged note's id.
class TagNotesPage extends ConsumerStatefulWidget {
  const TagNotesPage({super.key, required this.tag, this.fromNoteId});

  /// Without '#', lower-case.
  final String tag;

  /// The note whose tag was tapped: always part of a merge.
  final String? fromNoteId;

  @override
  ConsumerState<TagNotesPage> createState() => _TagNotesPageState();
}

class _TagNotesPageState extends ConsumerState<TagNotesPage> {
  late final Stream<List<NoteItem>> _notes = ref
      .read(notesRepositoryProvider)
      .watchNotes(tag: widget.tag, sort: NoteSort.updated);
  final _picked = <String>{};
  bool _merging = false;

  Future<void> _merge() async {
    final from = widget.fromNoteId;
    final ids = [?from, ..._picked];
    if (ids.length < 2 || _merging) return;
    setState(() => _merging = true);
    final repo = ref.read(notesRepositoryProvider);
    final undo = await repo.merge(ids, tag: widget.tag);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          persist: false,
          content: Text(
            '${ids.length} not birleşti, eskileri arşive kaldırıldı',
          ),
          action: SnackBarAction(
            label: 'Geri al',
            onPressed: () => repo.undoMerge(undo),
          ),
        ),
      );
    Navigator.of(context).pop(undo.mergedId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final from = widget.fromNoteId;
    final count = _picked.length + (from == null ? 0 : 1);
    return Scaffold(
      appBar: AppBar(title: Text('#${widget.tag}')),
      body: StreamBuilder<List<NoteItem>>(
        stream: _notes,
        builder: (context, snap) {
          final items = snap.data;
          if (items == null) return const SizedBox.shrink();
          // Picked notes that left the list (archived meanwhile) drop out.
          _picked.removeWhere((id) => !items.any((n) => n.id == id));
          if (items.isEmpty) {
            return const Center(child: Text('Bu etiketle not yok.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 120),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              final isFrom = item.id == from;
              final picked = _picked.contains(item.id);
              return _TagNoteTile(
                item: item,
                isFrom: isFrom,
                picked: picked,
                canMerge: from != null,
                onToggle: () => setState(() {
                  if (!_picked.remove(item.id)) _picked.add(item.id);
                }),
                onOpen: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NoteEditorPage(noteId: item.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: _picked.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  key: const Key('tag-merge'),
                  onPressed: _merging ? null : _merge,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  icon: const Icon(Icons.call_merge),
                  label: Text(
                    '$count notu birleştir · #${widget.tag}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _TagNoteTile extends StatelessWidget {
  const _TagNoteTile({
    required this.item,
    required this.isFrom,
    required this.picked,
    required this.canMerge,
    required this.onToggle,
    required this.onOpen,
  });

  final NoteItem item;
  final bool isFrom;
  final bool picked;
  final bool canMerge;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = NoteLinks.displayText(item.note.body);
    final rest = NoteText.rest(text);
    final edited = DateTime.fromMillisecondsSinceEpoch(item.note.updatedAt);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        side: BorderSide(
          color: isFrom || picked
              ? AppTokens.accentEnd
              : AppTokens.surfaceCardBorder,
          width: isFrom || picked ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Birleştir" at the start of every other note.
              if (canMerge)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: isFrom
                      ? const Chip(
                          label: Text('Bu not'),
                          visualDensity: VisualDensity.compact,
                        )
                      : FilterChip(
                          key: Key('merge-${item.id}'),
                          label: const Text('Birleştir'),
                          avatar: Icon(
                            picked ? Icons.check : Icons.call_merge,
                            size: 16,
                          ),
                          showCheckmark: false,
                          selected: picked,
                          onSelected: (_) => onToggle(),
                          visualDensity: VisualDensity.compact,
                        ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isEmpty ? '(boş not)' : item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (rest.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        rest,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTokens.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      NoteText.date(edited),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
