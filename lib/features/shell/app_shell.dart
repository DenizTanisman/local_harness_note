import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/secure_window.dart';
import '../../data/db/database_provider.dart';
import '../../theme/glow_background.dart';
import '../lessons/lesson_page.dart';
import '../lessons/lessons_page.dart';
import '../lessons/lessons_providers.dart';
import '../notes/note_editor_page.dart';
import '../notes/notes_page.dart';
import '../notes/notes_providers.dart';
import '../reminders/reminders_page.dart';
import '../settings/settings_button.dart';
import '../settings/settings_providers.dart';
import 'floating_nav_bar.dart';

/// Three tabs — Notlar · Hatırlatmalar · Dersler — with Settings in the
/// app bar.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  int _tab = 0;
  bool _secured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = await ref.read(settingsRepositoryProvider).loadAll();
      if (mounted && settings['flag_secure'] == 'true') {
        _secured = true;
        await SecureWindow.enable();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // The push isolate may have written with its own connection while we
      // were away: refresh the lists, then answer anything still waiting.
      final db = ref.read(databaseProvider);
      db.markTablesUpdated([
        db.notes,
        db.noteTags,
        db.reminders,
        db.appSettings,
      ]);
      ref.read(notesRepositoryProvider).purgeArchived();
      ref.read(pushProvider).processWork();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_secured) SecureWindow.disable();
    super.dispose();
  }

  void _newNote() => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => NoteEditorPage(addToReminders: _tab == 1),
    ),
  );

  Future<void> _addLesson() async {
    final lesson = await pickLesson(
      context,
      ref.read(lessonsRepositoryProvider),
    );
    if (lesson == null || !mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => LessonPage(lessonId: lesson.id)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(const ['Notlar', 'Hatırlatmalar', 'Dersler'][_tab]),
        actions: const [SettingsButton()],
      ),
      body: GlowBackground(
        child: IndexedStack(
          index: _tab,
          children: const [NotesPage(), RemindersPage(), LessonsPage()],
        ),
      ),
      // The floating bar sits over the content; lists pad their bottom.
      extendBody: true,
      bottomNavigationBar: FloatingNavBar(
        index: _tab,
        onSelect: (i) => setState(() => _tab = i),
        items: const [
          NavItem(Icons.sticky_note_2_outlined, Icons.sticky_note_2, 'Notlar'),
          NavItem(
            Icons.notifications_outlined,
            Icons.notifications,
            'Hatırlatmalar',
          ),
          NavItem(Icons.school_outlined, Icons.school, 'Dersler'),
        ],
        actionIcon: Icons.add,
        actionTooltip: const [
          'Yeni not',
          'Listeye yeni madde',
          'Ders ekle',
        ][_tab],
        onAction: _tab == 2 ? _addLesson : _newNote,
      ),
    );
  }
}
