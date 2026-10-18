import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/notes_repository.dart';
import '../../theme/app_tokens.dart';
import '../notes/note_editor_page.dart';
import '../notes/notes_providers.dart';
import '../settings/settings_providers.dart';

/// Reminders tab (spec §3.3): the ordered list the 07:30 · 14:00 · 20:00
/// notifications walk through. Drag to reorder, swipe to take off the list.
class RemindersPage extends ConsumerStatefulWidget {
  const RemindersPage({super.key});

  @override
  ConsumerState<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends ConsumerState<RemindersPage> {
  Stream<List<NoteItem>>? _items;
  List<NoteItem>? _optimistic;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(notesRepositoryProvider);
    final settings = ref.watch(settingsProvider).value ?? const {};
    final times =
        (settings[NotesRepository.reminderTimesKey] ??
                NotesRepository.defaultReminderTimes.join(','))
            .split(',');
    final enabled = settings['reminders_enabled'] != 'false';
    final next = settings[NotesRepository.cursorNoteKey];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: StreamBuilder<List<NoteItem>>(
          stream: _items ??= repo.watchReminders(),
          builder: (context, snap) {
            final items = _optimistic ?? snap.data;
            _optimistic = null;
            if (items == null) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    enabled
                        ? 'Her gün ${times.join(' · ')} — listeden sıradaki '
                              'gelir, bitince başa döner.'
                        : 'Hatırlatma bildirimleri kapalı (Ayarlar).',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (items.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'Liste boş.\nBir notta 🔔 ile ekle ya da sağ alttaki + ile yaz.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 120),
                      itemCount: items.length,
                      onReorderItem: (from, to) {
                        final ids = [for (final i in items) i.id];
                        ids.insert(to, ids.removeAt(from));
                        final moved = [...items];
                        moved.insert(to, moved.removeAt(from));
                        setState(() => _optimistic = moved);
                        repo.reorderReminders(ids);
                      },
                      itemBuilder: (context, i) {
                        final item = items[i];
                        final isNext =
                            item.id == next || (next == null && i == 0);
                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            child: const Text('Listeden çıkar'),
                          ),
                          onDismissed: (_) async {
                            final messenger = ScaffoldMessenger.of(context);
                            // Undo must also give back "Sıradaki".
                            final cursor = await repo.loadCursor();
                            await repo.removeFromReminders(item.id);
                            messenger.showSnackBar(
                              SnackBar(
                                persist: false,
                                content: const Text('Listeden çıkarıldı'),
                                action: SnackBarAction(
                                  label: 'Geri al',
                                  onPressed: () async {
                                    await repo.addToReminders(item.id);
                                    final ids = [for (final x in items) x.id];
                                    await repo.reorderReminders(ids);
                                    await repo.saveCursor(cursor);
                                  },
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            shape: isNext
                                ? RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTokens.radiusCard,
                                    ),
                                    side: const BorderSide(
                                      color: AppTokens.accentEnd,
                                      width: 1.5,
                                    ),
                                  )
                                : null,
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: isNext
                                    ? AppTokens.accentStart
                                    : AppTokens.surfaceCard,
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      item.title.isEmpty
                                          ? '(boş not)'
                                          : item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (item.media.contains('audio'))
                                    const Padding(
                                      padding: EdgeInsets.only(left: 6),
                                      child: Icon(Icons.mic, size: 16),
                                    ),
                                  if (item.media.contains('image'))
                                    const Padding(
                                      padding: EdgeInsets.only(left: 6),
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 16,
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: isNext
                                  ? const Text(
                                      'Sıradaki',
                                      style: TextStyle(
                                        color: AppTokens.textAccent,
                                      ),
                                    )
                                  : null,
                              trailing: ReorderableDragStartListener(
                                index: i,
                                child: const Icon(Icons.drag_handle),
                              ),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      NoteEditorPage(noteId: item.id),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
