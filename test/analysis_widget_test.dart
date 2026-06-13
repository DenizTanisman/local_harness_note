import 'package:daily_tracker/core/date_key.dart';
import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/database_provider.dart';
import 'package:daily_tracker/data/repositories/entry_repository.dart';
import 'package:daily_tracker/features/analysis/analysis_page.dart';
import 'package:daily_tracker/features/analysis/analysis_providers.dart';
import 'package:daily_tracker/features/analysis/heatmap_widget.dart';
import 'package:daily_tracker/features/shell/app_shell.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 3 acceptance (UI level): PageView swipe, heatmap cell tap moves
/// the date, future days not selectable, breakdown renders.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Widget app(Widget home) {
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: home),
    );
  }

  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  String daysAgo(int n) => dateKey(DateTime.now().subtract(Duration(days: n)));

  testWidgets('app shell opens on Main; bottom nav reaches Analysis', (
    tester,
  ) async {
    await tester.pumpWidget(app(const AppShell()));
    await tester.pumpAndSettle();
    // Opens on Main (index 2).
    expect(find.text('Daily Tracker'), findsOneWidget);

    await tester.tap(find.text('Analysis').last);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.widgetWithText(AppBar, 'Analysis'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('selected date defaults to yesterday', (tester) async {
    await tester.pumpWidget(app(const AnalysisPage()));
    await tester.pumpAndSettle();
    expect(find.text(daysAgo(1)), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('tapping a heatmap cell selects that day of the month', (
    tester,
  ) async {
    await tester.pumpWidget(app(const AnalysisPage()));
    await tester.pumpAndSettle();

    // Use last month so every column is a past, selectable day and the
    // month view sits scrolled to the left (selected near day 3).
    final now = DateTime.now();
    final prev = DateTime(now.year, now.month - 1, 1);
    final month =
        '${prev.year.toString().padLeft(4, '0')}-${prev.month.toString().padLeft(2, '0')}';
    container.read(selectedDateProvider.notifier).select('$month-03');
    await tester.pumpAndSettle();

    final grid = find.byKey(const ValueKey('heatmap-grid'));
    final box = tester.getRect(grid);
    const cell = 29.0; // _rowHeight
    // Column index 6 == day 7 (1-based).
    await tester.tapAt(Offset(box.left + cell * 6 + cell / 2, box.top + 10));
    await tester.pumpAndSettle();

    expect(container.read(selectedDateProvider), '$month-07');
    await closeApp(tester);
  });

  testWidgets('future dates are rejected by the notifier', (tester) async {
    await tester.pumpWidget(app(const AnalysisPage()));
    await tester.pumpAndSettle();

    final notifier = container.read(selectedDateProvider.notifier);
    final before = container.read(selectedDateProvider);
    notifier.select(dateKey(DateTime.now().add(const Duration(days: 2))));
    expect(container.read(selectedDateProvider), before);

    notifier.select(daysAgo(3));
    expect(container.read(selectedDateProvider), daysAgo(3));
    await closeApp(tester);
  });

  testWidgets('breakdown renders entry values for the selected day', (
    tester,
  ) async {
    final software = await (db.select(
      db.metrics,
    )..where((m) => m.key.equals('software'))).getSingle();
    await EntryRepository(db).saveEntry(
      metricId: software.id,
      date: daysAgo(1),
      numValue: 35,
      textValue: 'refactored parser',
    );

    await tester.pumpWidget(app(const AnalysisPage()));
    await tester.pumpAndSettle();

    expect(find.text('Software: 35 min'), findsOneWidget);
    // CR1-A: the note starts collapsed as a level-1 toggle row.
    expect(find.text('refactored parser'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('heatmap renders one labeled row per starred metric', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(const AnalysisPage()));
    await tester.pumpAndSettle();

    expect(find.byType(HeatmapWidget), findsOneWidget);
    for (final label in ['Software', 'Money', 'Brushing', 'Water']) {
      expect(
        find.descendant(
          of: find.byType(HeatmapWidget),
          matching: find.text(label),
        ),
        findsOneWidget,
        reason: label,
      );
    }
    await closeApp(tester);
  });
}
