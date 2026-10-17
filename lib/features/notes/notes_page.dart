import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/note_links.dart';
import '../../core/note_text.dart';
import '../../core/tag_tree.dart';
import '../../data/repositories/notes_repository.dart';
import '../../theme/app_tokens.dart';
import '../gemma/gemma_page.dart';
import '../gemma/gemma_prompt_sheet.dart';
import 'category_icon.dart';
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
  Stream<List<({String noteId, String tag})>>? _tagRows;
  String? _tagRowsStatus;
  Object? _notesKey;

  bool get _selecting => _selected.isNotEmpty;

  /// Tag tree source for the current Gelen/Arşiv view.
  Stream<List<({String noteId, String tag})>> _tagRowsStream(
    NotesRepository repo,
  ) {
    if (_tagRows == null || _tagRowsStatus != _status) {
      _tagRowsStatus = _status;
      _tagRows = repo.watchTagRows(status: _status);
    }
    return _tagRows!;
  }

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
                rows: _tagRowsStream(repo),
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
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 120),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return _NoteTile(
                          item: item,
                          selected: _selected.contains(item.id),
                          onTap: () =>
                              _selecting ? _toggle(item.id) : _open(item.id),
                          onLongPress: () => _toggle(item.id),
                          onGemma: () {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..hideCurrentMaterialBanner();
                            openGemma(context, ref, item.id);
                          },
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

/// [Gelen] [Arşiv] | [Kategoriler ▾]: the categories button opens a menu
/// with every #tag as a tree (`#question-llm` indented under `#question`),
/// note counts included. The picked tag shows its notes and everything
/// under it.
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.status,
    required this.tag,
    required this.rows,
    required this.onStatus,
    required this.onTag,
  });

  final String status;

  /// Picked tag path, e.g. "question-llm".
  final String? tag;
  final Stream<List<({String noteId, String tag})>> rows;
  final ValueChanged<String> onStatus;
  final ValueChanged<String?> onTag;

  /// The whole tree, depth first, with each node's depth.
  static List<(TagNode, int)> _flatten(
    List<({String noteId, String tag})> rows, [
    String? parent,
    int depth = 0,
  ]) => [
    for (final node in TagTree.children(rows, parent)) ...[
      (node, depth),
      ..._flatten(rows, node.path, depth + 1),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<({String noteId, String tag})>>(
      stream: rows,
      builder: (context, snap) {
        final tree = _flatten(snap.data ?? const []);
        final picked = tag;
        final label = picked == null
            ? 'Kategoriler'
            : picked.split(TagTree.separator).join(' › ').replaceAll('_', ' ');
        return SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: [
              for (final (value, text) in [
                ('inbox', 'Gelen'),
                ('archived', 'Arşiv'),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(text),
                    selected: status == value,
                    onSelected: (_) => onStatus(value),
                  ),
                ),
              const VerticalDivider(width: 12),
              MenuAnchor(
                alignmentOffset: const Offset(0, 6),
                style: MenuStyle(
                  backgroundColor: const WidgetStatePropertyAll(
                    AppTokens.menuFill,
                  ),
                  surfaceTintColor: const WidgetStatePropertyAll(
                    Colors.transparent,
                  ),
                  elevation: const WidgetStatePropertyAll(12),
                  shadowColor: const WidgetStatePropertyAll(Colors.black),
                  padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                      side: const BorderSide(color: AppTokens.navBarBorder),
                    ),
                  ),
                  maximumSize: WidgetStatePropertyAll(
                    Size(300, MediaQuery.sizeOf(context).height * 0.6),
                  ),
                ),
                menuChildren: [
                  _CategoryRow(
                    key: const Key('category-all'),
                    leading: const _AllIcon(),
                    label: 'Tümü',
                    selected: picked == null,
                    onPressed: () => onTag(null),
                  ),
                  if (tree.isNotEmpty)
                    const Divider(height: 12, indent: 8, endIndent: 8),
                  if (tree.isEmpty)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Text(
                        'Henüz kategori yok.\nNotta #yemek gibi yaz.',
                      ),
                    ),
                  for (final (node, depth) in tree)
                    depth == 0
                        ? _CategoryRow(
                            key: Key('category-${node.path}'),
                            leading: CategoryIcon(tag: node.path, size: 32),
                            label: node.name.replaceAll('_', ' '),
                            count: node.count,
                            selected: picked == node.path,
                            onPressed: () => onTag(node.path),
                          )
                        // Sub-tags keep the plain indented look.
                        : _CategoryRow(
                            key: Key('category-${node.path}'),
                            leading: SizedBox(
                              width: 32.0 + (depth - 1) * 18,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  picked == node.path
                                      ? Icons.check
                                      : Icons.subdirectory_arrow_right,
                                  size: 18,
                                  color: AppTokens.textSecondary,
                                ),
                              ),
                            ),
                            label: node.name.replaceAll('_', ' '),
                            count: node.count,
                            selected: picked == node.path,
                            dense: true,
                            onPressed: () => onTag(node.path),
                          ),
                ],
                builder: (context, controller, _) => FilterChip(
                  key: const Key('categories'),
                  avatar: picked == null
                      ? Icon(
                          controller.isOpen
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 18,
                        )
                      : CategoryIcon(tag: picked, size: 22),
                  label: Text(
                    label,
                    // Same contrast as the picked Gelen/Arşiv chip.
                    style: picked == null
                        ? null
                        : const TextStyle(color: Colors.white),
                  ),
                  selected: picked != null,
                  showCheckmark: false,
                  onSelected: (_) => controller.isOpen
                      ? controller.close()
                      : controller.open(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One row of the categories menu: icon, name, note count; the picked row
/// sits on the accent tint.
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    super.key,
    required this.leading,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.count,
    this.dense = false,
  });

  final Widget leading;
  final String label;
  final int? count;
  final bool selected;
  final bool dense;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return MenuItemButton(
      onPressed: onPressed,
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(260, dense ? 40 : 52)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 10),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        backgroundColor: WidgetStatePropertyAll(
          selected ? AppTokens.navSelectedFill : Colors.transparent,
        ),
        overlayColor: const WidgetStatePropertyAll(AppTokens.surfaceCard),
      ),
      leadingIcon: leading,
      trailingIcon: count == null
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTokens.surfaceCard,
                borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              ),
              child: Text(
                '$count',
                style: text.labelSmall?.copyWith(
                  color: AppTokens.textSecondary,
                ),
              ),
            ),
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          label,
          style: (dense ? text.bodyMedium : text.titleSmall)?.copyWith(
            color: selected ? AppTokens.textPrimary : null,
            fontWeight: dense ? FontWeight.w500 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AllIcon extends StatelessWidget {
  const _AllIcon();

  @override
  Widget build(BuildContext context) => Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: AppTokens.navSelectedFill,
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(
      Icons.grid_view_rounded,
      size: 18,
      color: AppTokens.accentEnd,
    ),
  );
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
    final preview =
        item.snippet ?? NoteText.rest(NoteLinks.displayText(item.note.body));
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
                    if (NotesRepository.deletesOn(item.note)
                        case final DateTime deletes)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _deletesLabel(deletes),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTokens.danger,
                          ),
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

/// "12 gün sonra silinecek" for an archived note.
String _deletesLabel(DateTime deletes) {
  final days = deletes.difference(DateTime.now()).inHours / 24;
  if (days <= 1) return 'Yarın silinecek';
  return '${days.ceil()} gün sonra silinecek';
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
        ? 'Arşiv boş.\nArşivdeki notlar 45 gün sonra kendiliğinden silinir.'
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
