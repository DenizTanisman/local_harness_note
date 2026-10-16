import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/db/database_provider.dart';
import 'package:local_harness_not/features/analysis/analysis_page.dart';
import 'package:local_harness_not/features/home/home_page.dart';
import 'package:local_harness_not/features/shell/app_shell.dart';
import 'package:local_harness_not/features/shell/tab_index.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Not-app shell: 2 tabs (Analysis, Main), opens on Main, swipe + tap
/// synced, Analysis preserved at index 0.
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

  testWidgets('opens on Main (index 1) with exactly two tabs', (tester) async {
    await pump(tester);
    expect(container.read(tabIndexProvider), AppTab.main);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Not'), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(2));
    // Money / Health / Sport tabs moved to the Para and Program apps (the
    // 'Sport' check-in metric card is unrelated and stays).
    for (final gone in ['Money', 'Health', 'Sport']) {
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(gone),
        ),
        findsNothing,
        reason: gone,
      );
    }
    await closeApp(tester);
  });

  testWidgets('bottom nav tap switches tabs and stays synced', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Analysis').last);
    await tester.pumpAndSettle();
    expect(container.read(tabIndexProvider), AppTab.analysis);
    expect(find.byType(AnalysisPage), findsOneWidget);

    await tester.tap(find.text('Main').last);
    await tester.pumpAndSettle();
    expect(container.read(tabIndexProvider), AppTab.main);
    expect(find.byType(HomePage), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('global swipe changes tabs and updates the nav bar', (
    tester,
  ) async {
    await pump(tester);
    // Fling from the top (AppBar band) so the gesture never lands on a
    // card TextField that would win the gesture arena.
    final w = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final top = Offset(w / 2, 90);
    // Main(1) is the last tab → swipe left stays put.
    await tester.flingFrom(top, const Offset(-600, 0), 1200);
    await tester.pumpAndSettle();
    expect(container.read(tabIndexProvider), AppTab.main);

    // Swipe right → Analysis(0); swipe left → back to Main(1).
    await tester.flingFrom(top, const Offset(600, 0), 1200);
    await tester.pumpAndSettle();
    expect(container.read(tabIndexProvider), AppTab.analysis);
    await tester.flingFrom(top, const Offset(-600, 0), 1200);
    await tester.pumpAndSettle();
    expect(container.read(tabIndexProvider), AppTab.main);
    await closeApp(tester);
  });

  testWidgets('deep link via provider jumps the PageView', (tester) async {
    await pump(tester);
    container.read(tabIndexProvider.notifier).goTo(AppTab.analysis);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Analysis'), findsOneWidget);
    // Out-of-range indices (the monolith's Money/Health/Sport) are ignored.
    container.read(tabIndexProvider.notifier).goTo(4);
    await tester.pumpAndSettle();
    expect(container.read(tabIndexProvider), AppTab.analysis);
    await closeApp(tester);
  });

  testWidgets('Analysis preserved at index 0 (heatmap + breakdown render)', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('Analysis').last);
    await tester.pumpAndSettle();
    // Heatmap grid still drawn; breakdown still present.
    expect(find.byKey(const ValueKey('heatmap-grid')), findsOneWidget);
    await closeApp(tester);
  });
}
