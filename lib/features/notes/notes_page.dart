import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/note_text.dart';
import '../../data/repositories/notes_repository.dart';
import '../../theme/app_tokens.dart';
import '../gemma/gemma_page.dart';
import 'note_editor_page.dart';
import 'notes_providers.dart';

/// Notes tab (spec §3.1): search, Gelen/Arşiv + tag chips, long-press
/// multi-select → merge / remind / archive, ✨ on every row.
class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final _search = TextEditingController();
  String _query = '';
  String _status = 'inbox';
  String? _tag;
  final _selected = <String>{};
  Stream<List<NoteItem>>? _notes;
  Stream<List<String>>? _tags;
  Object? _notesKey;

  bool get _selecting => _selected.isNotEmpty;

  /// Re-subscribes only when a filter changes, not on every rebuild.
  Stream<List<NoteItem>> _notesStream(NotesRepository repo) {
    final key = (_status, _query, _tag);
    if (_notes == null || key != _notesKey) {
      _notesKey = key;
      _notes = repo.watchNotes(status: _status, query: _query, tag: _tag);
    }
    return _notes!;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggle(String id) => setState(() {
    _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
  });

  Future<void> _merge() async {
    final repo = ref.read(notesRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final undo = await repo.merge(_selected.toList());
    setState(_selected.clear);
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 8),
        // Snackbars with an action persist by default — this one must not
        // linger over other screens' buttons.
        persist: false,
        content: const Text('Birleştirildi'),
        action: SnackBarAction(
          label: 'Geri al',
          onPressed: () => repo.undoMerge(undo),
        ),
      ),
    );
    if (!mounted) return;
    // Offer the obvious next step: tidy the merged note with Gemma.
    messenger.showMaterialBanner(
      MaterialBanner(
        content: const Text('Birleşen notu Gemma ile toparla?'),
        actions: [
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: const Text('Hayır'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Toparla'),
            onPressed: () {
              _push(GemmaPage(noteId: undo.mergedId));
            },
          ),
        ],
      ),
    );
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) messenger.hideCurrentMaterialBanner();
    });
  }

  Future<void> _bulk(
    Future<void> Function(NotesRepository, String) op,
    String done,
  ) async {
    final repo = ref.read(notesRepositoryProvider);
    final ids = _selected.toList();
    for (final id in ids) {
      await op(repo, id);
    }
    setState(_selected.clear);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${ids.length} not: $done')));
    }
  }

  /// Pushes [page] after clearing this screen's snackbar / banner, so an
  /// "undo" can never be tapped by accident on the next screen.
  void _push(Widget page) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..hideCurrentMaterialBanner();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _open(String? id) => _push(NoteEditorPage(noteId: id));

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(notesRepositoryProvider);
    return PopScope(
      canPop: !_selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(_selected.clear);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: _selecting
            ? null
            : FloatingActionButton(
                key: const Key('new-note'),
                tooltip: 'Yeni not',
                onPressed: () => _open(null),
                child: const Icon(Icons.add),
              ),
        body: SafeArea(
          child: Column(
            children: [
              if (_selecting)
                _selectionBar()
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    key: const Key('search'),
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: 'Notlarda ara  (#etiket de olur)',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() {
                                _search.clear();
                                _query = '';
                              }),
                            ),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              _FilterChips(
                status: _status,
                tag: _tag,
                tags: _tags ??= repo.watchTags(),
                onStatus: (s) => setState(() {
                  _status = s;
                  _selected.clear();
                }),
                onTag: (t) => setState(() => _tag = t),
              ),
              Expanded(
                child: StreamBuilder<List<NoteItem>>(
                  stream: _notesStream(repo),
                  builder: (context, snap) {
                    final items = snap.data;
                    if (items == null) return const SizedBox.shrink();
                    if (items.isEmpty) {
                      return _Empty(status: _status, query: _query);
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return _NoteTile(
                          item: item,
                          selected: _selected.contains(item.id),
                          onTap: () =>
                              _selecting ? _toggle(item.id) : _open(item.id),
                          onLongPress: () => _toggle(item.id),
                          onGemma: () => _push(GemmaPage(noteId: item.id)),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shown in place of the search field while notes are selected.
  Widget _selectionBar() => Padding(
    padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
    child: Row(
      children: [
        IconButton(
          tooltip: 'Seçimi kapat',
          icon: const Icon(Icons.close),
          onPressed: () => setState(_selected.clear),
        ),
        Expanded(
          child: Text(
            '${_selected.length} seçili',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          key: const Key('merge'),
          tooltip: 'Birleştir',
          icon: const Icon(Icons.call_merge),
          onPressed: _selected.length < 2 ? null : _merge,
        ),
        IconButton(
          tooltip: 'Hatırlatmaya ekle',
          icon: const Icon(Icons.notifications_active_outlined),
          onPressed: () =>
              _bulk((r, id) => r.addToReminders(id), 'hatırlatmaya eklendi'),
        ),
        _status == 'inbox'
            ? IconButton(
                tooltip: 'Arşivle',
                icon: const Icon(Icons.archive_outlined),
                onPressed: () => _bulk((r, id) => r.archive(id), 'arşivlendi'),
              )
            : IconButton(
                tooltip: 'Gelen kutusuna al',
                icon: const Icon(Icons.unarchive_outlined),
                onPressed: () =>
                    _bulk((r, id) => r.unarchive(id), 'gelen kutusuna alındı'),
              ),
      ],
    ),
  );
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.status,
    required this.tag,
    required this.tags,
    required this.onStatus,
    required this.onTag,
  });

  final String status;
  final String? tag;
  final Stream<List<String>> tags;
  final ValueChanged<String> onStatus;
  final ValueChanged<String?> onTag;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: StreamBuilder<List<String>>(
        stream: tags,
        builder: (context, snap) {
          final all = snap.data ?? const <String>[];
          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: [
              for (final (value, label) in [
                ('inbox', 'Gelen'),
                ('archived', 'Arşiv'),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: status == value,
                    onSelected: (_) => onStatus(value),
                  ),
                ),
              if (all.isNotEmpty) const VerticalDivider(width: 12),
              for (final t in all)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text('#$t'),
                    selected: tag == t,
                    onSelected: (on) => onTag(on ? t : null),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    required this.onGemma,
  });

  final NoteItem item;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onGemma;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = item.snippet ?? NoteText.rest(item.note.body);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        side: BorderSide(
          color: selected ? AppTokens.accentEnd : AppTokens.surfaceCardBorder,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 2),
                  child: Icon(Icons.check_circle, color: AppTokens.accentEnd),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title.isEmpty ? '(boş not)' : item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (item.note.isPrivate)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.lock,
                              size: 16,
                              color: AppTokens.textSecondary,
                            ),
                          ),
                        if (item.inReminders)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.notifications_active,
                              size: 16,
                              color: AppTokens.textAccent,
                            ),
                          ),
                      ],
                    ),
                    if (preview.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    if (item.tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          item.tags.map((t) => '#$t').join('  '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTokens.textAccent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Gemma ile toparla',
                icon: const Icon(
                  Icons.auto_awesome,
                  color: AppTokens.accentEnd,
                ),
                onPressed: onGemma,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.status, required this.query});

  final String status;
  final String query;

  @override
  Widget build(BuildContext context) {
    final text = query.isNotEmpty
        ? 'Eşleşen not yok'
        : status == 'archived'
        ? 'Arşiv boş'
        : 'Henüz not yok.\n+ ile ilk notunu yaz.';
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
