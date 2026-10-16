import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/secure_window.dart';
import '../../data/db/database_provider.dart';
import '../../theme/glow_background.dart';
import '../notes/notes_page.dart';
import '../notes/notes_providers.dart';
import '../reminders/reminders_page.dart';
import '../settings/settings_button.dart';
import '../settings/settings_providers.dart';

/// Two tabs — Notlar · Hatırlatmalar — with Settings in the app bar.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tab == 0 ? 'Notlar' : 'Hatırlatmalar'),
        actions: const [SettingsButton()],
      ),
      body: GlowBackground(
        child: IndexedStack(
          index: _tab,
          children: const [NotesPage(), RemindersPage()],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sticky_note_2_outlined),
            selectedIcon: Icon(Icons.sticky_note_2),
            label: 'Notlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Hatırlatmalar',
          ),
        ],
      ),
    );
  }
}
