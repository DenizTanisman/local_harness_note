import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'data/db/database_provider.dart';
import 'features/backup/backup_worker.dart';
import 'features/home/home_providers.dart';
import 'features/notifications/notification_service.dart';
import 'features/screentime/screentime_providers.dart';
import 'features/shell/app_shell.dart';
import 'features/shell/tab_index.dart';
import 'theme/app_theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    ref.watch(databaseProvider),
    onTapPayload: (payload) {
      // Notification entry always lands on TODAY (CR1-D).
      ref.read(homeDateProvider.notifier).resetToToday();
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
      // Land on Main, or jump to the Money tab for an expense reminder
      // (CR-3 §2 — a tab switch, not a pushed route).
      ref
          .read(tabIndexProvider.notifier)
          .goTo(payload == 'money' ? AppTab.money : AppTab.main);
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
          child: const DailyTrackerApp(),
        ),
      );
      // Initialize notifications after the first frame; reschedule the whole
      // local queue on every app open (spec §8).
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final service = container.read(notificationServiceProvider);
        await service.init();
        await service.rescheduleAll();
        // CR-4 §6: pull today's screen time on open (silent without
        // permission — no repeated prompts).
        await container.read(screenTimeRepositoryProvider).sync();
      });
    },
    (error, stack) {
      debugPrint('Uncaught: $error');
    },
  );
}

class DailyTrackerApp extends StatelessWidget {
  const DailyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Tracker',
      navigatorKey: navigatorKey,
      // Single dark theme built from tokens (CR1-B rule 7).
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
}
