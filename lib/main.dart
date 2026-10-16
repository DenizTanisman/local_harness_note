import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'core/hub_snapshot_publisher.dart';
import 'data/db/database_provider.dart';
import 'features/backup/backup_worker.dart';
import 'features/home/home_providers.dart';
import 'features/home/instagram_autofill.dart';
import 'features/notifications/notification_service.dart';
import 'features/shell/app_shell.dart';
import 'features/shell/tab_index.dart';
import 'theme/app_theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    ref.watch(databaseProvider),
    onTapPayload: (payload) {
      // Notification entry always lands on TODAY's check-in (CR1-D).
      ref.read(homeDateProvider.notifier).resetToToday();
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
      ref.read(tabIndexProvider.notifier).goTo(AppTab.main);
    },
  );
});

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        // Errors must never include DB contents or the backup password
        // (spec §11.7) — only the framework diagnostics are logged.
      };
      Workmanager().initialize(backupCallbackDispatcher);
      final container = ProviderContainer();
      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const NotApp(),
        ),
      );
      // Initialize notifications after the first frame; reschedule the whole
      // local queue on every app open (spec §8).
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // CR-4 §3.3: Instagram minutes from the Program app's hub snapshot
        // (silent no-op when Program is not installed).
        await container.read(instagramAutofillProvider).run();
        // Hub contract §5: publish once after the startup syncs, then keep
        // the snapshot fresh on DB writes and when backgrounded. Must run
        // before notification init — that awaits the Android 13+ permission
        // dialog, and the hub would see no data until the user answers it.
        await container.read(hubSnapshotPublisherProvider).start();
        final service = container.read(notificationServiceProvider);
        await service.init();
        await service.rescheduleAll();
      });
    },
    (error, stack) {
      debugPrint('Uncaught: $error');
    },
  );
}

class NotApp extends StatelessWidget {
  const NotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Not',
      navigatorKey: navigatorKey,
      // Single dark theme built from tokens (CR1-B rule 7).
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
}
