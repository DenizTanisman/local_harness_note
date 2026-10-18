import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'core/hub_snapshot_publisher.dart';
import 'core/note_text.dart';
import 'core/system_channel.dart';
import 'data/db/database_provider.dart';
import 'data/repositories/notes_repository.dart';
import 'features/backup/backup_worker.dart';
import 'features/lessons/lesson_page.dart';
import 'features/lessons/lessons_providers.dart';
import 'features/notes/attachments_view.dart';
import 'features/notes/note_editor_page.dart';
import 'features/notes/video_view.dart';
import 'features/notifications/notification_actions.dart';
import 'features/notes/notes_providers.dart';
import 'features/notifications/notification_service.dart';
import 'features/quick/quick_note_page.dart';
import 'features/settings/settings_page.dart' show bubbleEnabledKey;
import 'features/settings/settings_providers.dart';
import 'features/shell/app_shell.dart';
import 'theme/app_theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

/// Opens a note (reminder tap) or a new one (widget / share sheet).
void openEditor({
  String? noteId,
  String? text,
  ({String path, String mime})? media,
  String source = 'phone',
}) {
  final nav = navigatorKey.currentState;
  if (nav == null) return;
  nav.popUntil((route) => route.isFirst);
  nav.push(
    MaterialPageRoute(
      builder: (_) => NoteEditorPage(
        noteId: noteId,
        initialText: text,
        initialMedia: media,
        source: source,
      ),
    ),
  );
}

/// Opens a lesson, scrolled to [section]; with [recall] straight into that
/// section's test (review reminder tap).
void openLesson(String lessonId, {String? section, bool recall = false}) {
  final nav = navigatorKey.currentState;
  if (nav == null) return;
  nav.popUntil((route) => route.isFirst);
  nav.push(
    MaterialPageRoute(
      builder: (_) =>
          LessonPage(lessonId: lessonId, section: section, recall: recall),
    ),
  );
}

/// "🎬 İzle" on a reminder: the video, full screen.
Future<void> _openVideo(String attachmentId) async {
  final context = navigatorKey.currentContext;
  if (context == null) return;
  final repo = ProviderScope.containerOf(
    context,
  ).read(attachmentsRepositoryProvider);
  final attachment = await repo.get(attachmentId);
  if (attachment == null) return;
  final file = await repo.fileOf(attachment);
  final note = await NotesRepository(repo.db).getNote(attachment.noteId);
  final nav = navigatorKey.currentState;
  if (nav == null) return;
  nav.popUntil((route) => route.isFirst);
  nav.push(
    MaterialPageRoute(
      builder: (_) => VideoPlayerPage(
        file: file,
        title: note == null ? null : NoteText.title(note.body, max: 60),
      ),
    ),
  );
}

void _openPayload(String? payload) {
  if (payload == null) return;
  if (payload.startsWith(watchActionPrefix)) {
    unawaited(_openVideo(payload.substring(watchActionPrefix.length)));
  } else if (payload.startsWith('note:')) {
    openEditor(noteId: payload.substring(5));
  } else if (payload.startsWith('recall:')) {
    final parts = payload.substring(7).split(':');
    if (parts.length == 2) {
      openLesson(parts[0], section: parts[1], recall: true);
    }
  }
}

void _openIntent(AppIntent intent) {
  final html = intent.lessonHtml;
  final media = intent.mediaPath;
  if (html != null) {
    unawaited(_importLesson(html));
  } else if (media != null) {
    openEditor(
      text: intent.sharedText,
      media: (path: media, mime: intent.mediaMime ?? 'audio/mpeg'),
      source: 'share',
    );
  } else if (intent.sharedText != null) {
    openEditor(text: intent.sharedText, source: 'share');
  } else {
    openEditor();
  }
}

/// An .html opened with / shared to Not: add it and open it.
Future<void> _importLesson(String html) async {
  final context = navigatorKey.currentContext;
  if (context == null) return;
  final repo = ProviderScope.containerOf(
    context,
  ).read(lessonsRepositoryProvider);
  final lesson = await importLesson(context, repo, html);
  if (lesson != null) openLesson(lesson.id);
}

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
      // Streamline "Pixel" icons are CC BY 4.0: credit them on the
      // licenses page.
      LicenseRegistry.addLicense(() async* {
        yield LicenseEntryWithLineBreaks([
          'Streamline Pixel icons',
        ], await rootBundle.loadString('assets/icons/pixel/LICENSE.md'));
      });
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

        // Archived notes older than 45 days go first, then files of
        // attachments whose note is gone.
        await container.read(notesRepositoryProvider).purgeArchived();
        unawaited(container.read(attachmentsRepositoryProvider).sweep());
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
