import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db/database_provider.dart';
import 'features/money/money_page.dart';
import 'features/notifications/notification_service.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
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
}

class DailyTrackerApp extends StatelessWidget {
  const DailyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Tracker',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF39D353),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const RootPager(),
    );
  }
}
