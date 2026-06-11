import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'data/db/database_provider.dart';
import 'features/backup/backup_worker.dart';
import 'features/money/money_page.dart';
import 'features/notifications/notification_service.dart';
import 'features/settings/settings_providers.dart';
import 'features/shell/root_pager.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    ref.watch(databaseProvider),
    onTapPayload: (payload) {
      final navigator = navigatorKey.currentState;
      if (navigator == null) return;
      // Always land on the home page first (spec 6.1/§8).
      navigator.popUntil((route) => route.isFirst);
      if (payload == 'money') {
        navigator.push(
            MaterialPageRoute(builder: (_) => const MoneyPage()));
      }
    },
  );
});

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      // Errors must never include DB contents or the backup password
      // (spec §11.7) — only the framework diagnostics are logged.
    };
    Workmanager().initialize(backupCallbackDispatcher);
    final container = ProviderContainer();
    runApp(UncontrolledProviderScope(
      container: container,
      child: const DailyTrackerApp(),
    ));
    // Initialize notifications after the first frame; reschedule the whole
    // local queue on every app open (spec §8).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final service = container.read(notificationServiceProvider);
      await service.init();
      await service.rescheduleAll();
    });
  }, (error, stack) {
    debugPrint('Uncaught: $error');
  });
}

class DailyTrackerApp extends ConsumerWidget {
  const DailyTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value ?? const {};
    final themeMode = switch (settings['theme_mode']) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
    return MaterialApp(
      title: 'Daily Tracker',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF39D353),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF39D353),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: themeMode,
      home: const RootPager(),
    );
  }
}
