import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/note_text.dart';
import '../../core/selection_menu.dart';
import '../../data/db/app_database.dart';
import '../../theme/app_tokens.dart';
import '../../data/db/database_provider.dart';
import '../gemma/gemma_prompt_sheet.dart';
import '../notifications/notification_service.dart';
import 'attachments_view.dart';
import 'notes_providers.dart';
import 'link_action_bar.dart';
import 'note_body_view.dart';
import 'tag_suggestion_bar.dart';

/// Plain-text editor (spec §3.2) with auto-save. A new note opens with the
/// keyboard up and is only stored once it has text.
class NoteEditorPage extends ConsumerStatefulWidget {
  const NoteEditorPage({
    super.key,
    this.noteId,
    this.initialText,
    this.initialMedia,
    this.source = 'phone',
    this.addToReminders = false,
  });

  /// null → new note.
  final String? noteId;
  final String? initialText;

  /// A voice message / picture shared to Not: attached right away.
  final ({String path, String mime})? initialMedia;
  final String source;

  /// New notes created from the reminders tab join the list.
  final bool addToReminders;

  @override
  ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  late final _selectionMenu = SelectionMenuOnRange(_text, _focus);
  String? _id;
  Note? _note;
  bool _inReminders = false;
  bool _loading = true;

  /// Existing notes open as they read (links tappable); a tap on the text
  /// switches to editing at that spot. New notes start in editing.
  late bool _editing = widget.noteId == null;
  Timer? _save;
  String _saved = '';
  StreamSubscription<Note?>? _watch;
  @override
  void initState() {
    super.initState();
    _id = widget.noteId;
    _selectionMenu; // start listening
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(notesRepositoryProvider);
    if (_id != null) {
      final note = await repo.getNote(_id!);
      _note = note;
      _text.text = _saved = note?.body ?? '';
      _inReminders = (await repo.reminderNotes()).any((n) => n.id == _id);
      _listen();
    } else {
      _text.text = widget.initialText ?? '';
      if (_text.text.isNotEmpty) _scheduleSave();
    }
    setState(() => _loading = false);
    final media = widget.initialMedia;
    if (media != null) await _attachFile(media.path, media.mime);
    if (_id == null) {
      // After the field exists: focus it and make sure the keyboard shows
      // (a cold start from the widget focuses without raising it).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _focus.requestFocus();
        Future<void>.delayed(const Duration(milliseconds: 350), () {
          if (mounted && _focus.hasFocus) {
            SystemChannels.textInput.invokeMethod<void>('TextInput.show');
          }
        });
      });
    }
  }

  void _listen() {
    _watch?.cancel();
    _watch = ref.read(notesRepositoryProvider).watchNote(_id!).listen((n) {
      if (!mounted || n == null) return;
      setState(() => _note = n);
      // Changed elsewhere (Gemma, a revert, Claude) while nothing is pending
      // here → show the new text.
      if (n.body != _saved && _text.text == _saved && _save == null) {
        _text.text = _saved = n.body;
      }
    });
  }

  void _scheduleSave() {
    _save?.cancel();
    _save = Timer(const Duration(milliseconds: 600), _flush);
  }

  Future<void> _flush() async {
    _save?.cancel();
    _save = null;
    final body = _text.text;
    if (body == _saved) return;
    final repo = ref.read(notesRepositoryProvider);
    if (_id == null) {
      if (body.trim().isEmpty) return;
      _id = await repo.create(body, source: widget.source);
      if (widget.addToReminders) {
        await repo.addToReminders(_id!);
        _inReminders = true;
      }
      if (mounted) _listen();
    } else {
      await repo.updateBody(_id!, body);
    }
    _saved = body;
  }

  /// Saves and makes sure the note exists (needed before ✨ / 🔔 / 🔒).
  Future<String?> _ensureSaved() async {
    await _flush();
    if (_id == null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Önce bir şey yaz')));
    }
    return _id;
  }

  void _startEditing(int offset) {
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _text.selection = TextSelection.collapsed(
        offset: offset.clamp(0, _text.text.length),
      );
      _focus.requestFocus();
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    });
  }

  Future<void> _stopEditing() async {
    _focus.unfocus();
    setState(() => _editing = false);
    await _flush();
  }

  Future<void> _close() async {
    // Runs while the page is being disposed: take what we need first.
    final repo = ref.read(notesRepositoryProvider);
    final attachments = ref.read(attachmentsRepositoryProvider);
    final emptied = _text.text.trim().isEmpty;
    await _flush();
    // A note emptied out is not worth keeping — unless it holds a voice
    // clip or a picture.
    if (_id != null && emptied && (await attachments.of(_id!)).isEmpty) {
      await repo.delete(_id!);
    }
  }

  Future<void> _attach() async {
    final picked = await pickAttachment(context);
    if (picked != null) await _attachFile(picked.path, picked.mime);
  }

  /// Attaches a file; a note without text yet gets a title so it can be
  /// stored (and named in lists and notifications).
  Future<void> _attachFile(String path, String mime) async {
    if (_text.text.trim().isEmpty) {
      _text.text = mime.startsWith('image/') ? 'Görsel' : 'Sesli not';
    }
    await _flush();
    final id = _id;
    if (id == null) return;
    final added = await ref
        .read(attachmentsRepositoryProvider)
        .add(id, path, mime);
    // Recordings, picker and share copies sit in the cache: the note has
    // its own copy now.
    final cache = await getTemporaryDirectory();
    if (p.isWithin(cache.path, path)) {
      try {
        await File(path).delete();
      } on FileSystemException {
        // Already gone.
      }
    }
    if (added == null) {
      _snack('Dosya eklenemedi');
    } else if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _save?.cancel();
    _watch?.cancel();
    _selectionMenu.dispose();
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _gemma() async {
    final id = await _ensureSaved();
    if (id == null || !mounted) return;
    await openGemma(context, ref, id);
    final note = await ref.read(notesRepositoryProvider).getNote(id);
    if (note != null && mounted) {
      setState(() => _text.text = _saved = note.body);
    }
  }

  Future<void> _toggleReminder() async {
    final id = await _ensureSaved();
    if (id == null) return;
    final repo = ref.read(notesRepositoryProvider);
    if (_inReminders) {
      await repo.removeFromReminders(id);
    } else {
      if (_note?.status == 'archived') await repo.unarchive(id);
      await repo.addToReminders(id);
    }
    setState(() => _inReminders = !_inReminders);
    _snack(
      _inReminders ? 'Hatırlatma listesine eklendi' : 'Listeden çıkarıldı',
    );
  }

  Future<void> _togglePrivate() async {
    final id = await _ensureSaved();
    if (id == null) return;
    final next = !(_note?.isPrivate ?? false);
    await ref.read(notesRepositoryProvider).setPrivate(id, next);
    _snack(next ? 'Özel: Claude bu notu göremez' : 'Özel değil');
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _menu(String action) async {
    final id = await _ensureSaved();
    if (id == null || !mounted) return;
    final repo = ref.read(notesRepositoryProvider);
    switch (action) {
      case 'archive':
        await repo.archive(id);
        if (mounted) Navigator.of(context).pop();
      case 'unarchive':
        await repo.unarchive(id);
        _snack('Gelen kutusuna alındı');
      case 'preview':
        await NotificationService.preview(ref.read(databaseProvider), id);
      case 'versions':
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => _VersionsSheet(noteId: id),
        );
      case 'delete':
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Not silinsin mi?'),
            content: const Text('Bu geri alınamaz. Arşivlemek daha güvenli.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Vazgeç'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTokens.danger,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sil'),
              ),
            ],
          ),
        );
        if (ok == true) {
          _save?.cancel();
          await repo.delete(id);
          _id = null;
          _text.clear();
          if (mounted) Navigator.of(context).pop();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final private = _note?.isPrivate ?? false;
    final archived = _note?.status == 'archived';
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _note == null
                ? 'Yeni not'
                : NoteText.date(
                    DateTime.fromMillisecondsSinceEpoch(_note!.createdAt),
                  ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          actions: [
            if (_editing && _id != null)
              IconButton(
                key: const Key('editor-done'),
                tooltip: 'Bitti',
                icon: const Icon(Icons.check),
                onPressed: _stopEditing,
              ),
            IconButton(
              key: const Key('editor-gemma'),
              tooltip: 'Gemma ile toparla',
              icon: const Icon(Icons.auto_awesome, color: AppTokens.accentEnd),
              onPressed: _gemma,
            ),
            IconButton(
              key: const Key('editor-attach'),
              tooltip: 'Ses ya da görsel ekle',
              icon: const Icon(Icons.attach_file),
              onPressed: _attach,
            ),
            IconButton(
              key: const Key('editor-remind'),
              tooltip: _inReminders ? 'Hatırlatmadan çıkar' : 'Hatırlat',
              icon: Icon(
                _inReminders
                    ? Icons.notifications_active
                    : Icons.notifications_none,
                color: _inReminders ? AppTokens.textAccent : null,
              ),
              onPressed: _toggleReminder,
            ),
            IconButton(
              key: const Key('editor-private'),
              tooltip: private ? 'Özel (Claude göremez)' : 'Özel yap',
              icon: Icon(private ? Icons.lock : Icons.lock_open),
              onPressed: _togglePrivate,
            ),
            PopupMenuButton<String>(
              onSelected: _menu,
              itemBuilder: (_) => [
                archived
                    ? const PopupMenuItem(
                        value: 'unarchive',
                        child: Text('Gelen kutusuna al'),
                      )
                    : const PopupMenuItem(
                        value: 'archive',
                        child: Text('Arşivle'),
                      ),
                const PopupMenuItem(
                  value: 'preview',
                  child: Text('Bildirimi önizle'),
                ),
                const PopupMenuItem(value: 'versions', child: Text('Sürümler')),
                const PopupMenuItem(value: 'delete', child: Text('Sil')),
              ],
            ),
          ],
        ),
        body: _loading
            ? const SizedBox.shrink()
            : !_editing
            ? GestureDetector(
                // Below the text: edit at the end.
                behavior: HitTestBehavior.opaque,
                onTap: () => _startEditing(_text.text.length),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_id != null)
                        AttachmentStrip(
                          noteId: _id!,
                          title: NoteText.title(_text.text, max: 60),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: NoteBodyView(
                          key: const Key('editor-view'),
                          body: _text.text,
                          onTapText: _startEditing,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  if (_id != null)
                    AttachmentStrip(
                      noteId: _id!,
                      title: NoteText.title(_text.text, max: 60),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: TextField(
                        key: const Key('editor-text'),
                        controller: _text,
                        focusNode: _focus,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        textAlignVertical: TextAlignVertical.top,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          hintText: 'Yaz…  (#etiket ekleyebilirsin)',
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onChanged: (_) => _scheduleSave(),
                      ),
                    ),
                  ),
                  TagSuggestionBar(
                    controller: _text,
                    focusNode: _focus,
                    onChanged: _scheduleSave,
                  ),
                  LinkActionBar(
                    controller: _text,
                    focusNode: _focus,
                    onChanged: _scheduleSave,
                  ),
                ],
              ),
      ),
    );
  }
}

/// Earlier bodies of a note; tap one to bring it back (the current text is
/// kept as a version too).
class _VersionsSheet extends ConsumerWidget {
  const _VersionsSheet({required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(notesRepositoryProvider);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      builder: (context, scroll) => StreamBuilder<List<NoteVersion>>(
        stream: repo.watchVersions(noteId),
        builder: (context, snap) {
          final versions = snap.data ?? const <NoteVersion>[];
          return ListView(
            controller: scroll,
            padding: const EdgeInsets.all(16),
            children: [
              Text('Sürümler', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (versions.isEmpty)
                const Text(
                  'Henüz eski sürüm yok. Gemma onayı veya geri dönüş '
                  'olunca burada görünür.',
                ),
              for (final v in versions)
                Card(
                  child: ListTile(
                    title: Text(
                      v.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${NoteText.date(DateTime.fromMillisecondsSinceEpoch(v.createdAt))}'
                      ' · ${v.reason == 'gemma' ? 'Gemma öncesi' : 'geri dönüş öncesi'}',
                    ),
                    trailing: TextButton(
                      child: const Text('Bu sürüme dön'),
                      onPressed: () async {
                        await repo.revertTo(v);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
