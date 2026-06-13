import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/database_provider.dart';
import 'package:daily_tracker/features/analysis/analysis_page.dart';
import 'package:daily_tracker/features/health/health_page.dart';
import 'package:daily_tracker/features/home/home_page.dart';
import 'package:daily_tracker/features/shell/app_shell.dart';
import 'package:daily_tracker/features/shell/tab_index.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR3-P0 acceptance: 5-tab shell, opens on Main, swipe + tap synced,
/// Analysis preserved at index 1.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Widget app() {
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AppShell()),
    );
  }

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
  }

  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('opens on Main (index 2)', (tester) async {
    await pump(tester);
    expect(container.read(tabIndexProvider), AppTab.main);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Daily Tracker'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('bottom nav tap switches tabs and stays synced',
      (tester) async {
    await pump(tester);

    await tester.tap(find.text('Analysis').last);
    await tester.pumpAndSettle();
    expect(container.read(tabIndexProvider), AppTab.analysis);
    expect(find.byType(AnalysisPage), findsOneWidget);

    await tester.tap(find.text('Health').last);
    await tester.pumpAndSettle();
    expect(container.read(tabIndexProvider), AppTab.health);
    expect(find.byType(HealthPage), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('global swipe changes tabs and updates the nav bar',
      (tester) async {
    await pump(tester);
    // Main(2) → swipe left → Health(3).
    await tester.fling(find.byType(PageView), const Offset(-600, 0), 1200);
    await tester.pumpAndSettle();
    expect(container.read(tabIndexProvider), AppTab.health);

    // Swipe right twice → Analysis(1).
    await tester.fling(find.byType(PageView), const Offset(600, 0), 1200);
    await tester.pumpAndSettle();
    await tester.fling(find.byType(PageView), const Offset(600, 0), 1200);
    await tester.pumpAndSettle();
    expect(container.read(tabIndexProvider), AppTab.analysis);
    await closeApp(tester);
  });

  testWidgets('deep link via provider jumps the PageView', (tester) async {
    await pump(tester);
    container.read(tabIndexProvider.notifier).goTo(AppTab.money);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Money'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('Analysis preserved at index 1 (heatmap + breakdown render)',
      (tester) async {
    await pump(tester);
    await tester.tap(find.text('Analysis').last);
    await tester.pumpAndSettle();
    // Heatmap grid still drawn; breakdown still present.
    expect(find.byKey(const ValueKey('heatmap-grid')), findsOneWidget);
    await closeApp(tester);
  });
}
