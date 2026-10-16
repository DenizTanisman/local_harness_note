import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'core/hub_snapshot_publisher.dart';
import 'core/system_channel.dart';
import 'data/db/database_provider.dart';
import 'features/backup/backup_worker.dart';
import 'features/notes/note_editor_page.dart';
import 'features/notes/notes_providers.dart';
import 'features/notifications/notification_service.dart';
import 'features/quick/quick_note_page.dart';
import 'features/settings/settings_page.dart' show bubbleEnabledKey;
import 'features/settings/settings_providers.dart';
import 'features/shell/app_shell.dart';
import 'theme/app_theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

/// Opens a note (reminder tap) or a new one (widget / share sheet).
void openEditor({String? noteId, String? text, String source = 'phone'}) {
  final nav = navigatorKey.currentState;
  if (nav == null) return;
  nav.popUntil((route) => route.isFirst);
  nav.push(
    MaterialPageRoute(
      builder: (_) =>
          NoteEditorPage(noteId: noteId, initialText: text, source: source),
    ),
  );
}

void _openPayload(String? payload) {
  if (payload != null && payload.startsWith('note:')) {
    openEditor(noteId: payload.substring(5));
  }
}

void _openIntent(AppIntent intent) => intent.sharedText == null
    ? openEditor()
    : openEditor(text: intent.sharedText, source: 'share');

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService(
    ref.watch(databaseProvider),
    onTapPayload: _openPayload,
  );
  ref.onDispose(service.dispose);
  return service;
});

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        // Framework diagnostics only — never note contents.
        FlutterError.presentError(details);
      };
      Workmanager().initialize(backupCallbackDispatcher);
      final container = ProviderContainer();
      runApp(
        UncontrolledProviderScope(container: container, child: const NotApp()),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        SystemChannel.listen(_openIntent);
        final launch = await SystemChannel.takeLaunchIntent();
        if (launch != null) _openIntent(launch);

        // Bring the quick-note bubble back (after a reboot or a dismiss).
        final settings = await container
            .read(settingsRepositoryProvider)
            .loadAll();
        if (settings[bubbleEnabledKey] == 'true') {
          final bubble = await SystemChannel.bubbleStatus();
          if (bubble != null && !bubble.showing) {
            await SystemChannel.showBubble();
          }
        }

        // Archived notes older than 45 days go first.
        await container.read(notesRepositoryProvider).purgeArchived();
        await container.read(hubSnapshotPublisherProvider).start();
        // Claude connection: register the push token and answer anything
        // that queued up while the app was closed (no-op when unpaired).
        unawaited(container.read(pushProvider).start());

        final service = container.read(notificationServiceProvider);
        await service.init();
        _openPayload(await service.launchPayload());
        await service.rescheduleAll();
        service.watchChanges();
      });
    },
    (error, stack) {
      debugPrint('Uncaught: ${error.runtimeType}');
    },
  );
}

/// Entry point of the quick-note bubble (BubbleActivity): its own small
/// app on its own engine and DB connection.
@pragma('vm:entry-point')
void bubbleMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'Hızlı not',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: const Locale('tr'),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const QuickNotePage(),
      ),
    ),
  );
}

class NotApp extends StatelessWidget {
  const NotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Not',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Turkish system strings (time picker, back, menus).
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const AppShell(),
    );
  }
}
