import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/database_provider.dart';
import 'package:daily_tracker/data/repositories/screen_time_repository.dart';
import 'package:daily_tracker/features/health/health_page.dart';
import 'package:daily_tracker/features/home/home_page.dart';
import 'package:daily_tracker/features/screentime/screentime_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR4-P1 acceptance: onboarding without permission; top-5 bars with
/// permission; Main screen-time summary line.
class _FakeSource implements ScreenTimeSource {
  _FakeSource({this.granted = false, this.raw});
  bool granted;
  Map<String, AppUsage>? raw;
  @override
  Future<bool> hasPermission() async => granted;
  @override
  Future<void> openPermissionSettings() async {}
  @override
  Future<Map<String, AppUsage>?> rawUsageFor(DateTime day) async => raw;
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Widget app(Widget home, ScreenTimeSource source) {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        screenTimeSourceProvider.overrideWithValue(source),
      ],
    );
    addTearDown(container.dispose);
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: home),
    );
  }

  Future<void> pump(
    WidgetTester tester,
    Widget home,
    ScreenTimeSource source,
  ) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(home, source));
    await tester.pumpAndSettle();
  }

  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('Health shows onboarding without Usage Access', (tester) async {
    await pump(tester, const HealthPage(), _FakeSource(granted: false));
    await tester.scrollUntilVisible(
      find.text('Screen Time'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const ValueKey('screentime-connect')), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('Health shows total + top-5 when data is stored', (tester) async {
    // Pre-store today's screen time.
    final repo = ScreenTimeRepository(
      db,
      _FakeSource(
        granted: true,
        raw: {
          'com.instagram.android': const AppUsage(
            packageName: 'com.instagram.android',
            label: 'Instagram',
            foregroundMinutes: 65,
          ),
          'com.whatsapp': const AppUsage(
            packageName: 'com.whatsapp',
            label: 'WhatsApp',
            foregroundMinutes: 38,
          ),
        },
      ),
    );
    await repo.sync(day: DateTime.now());

    await pump(tester, const HealthPage(), _FakeSource(granted: true));
    await tester.scrollUntilVisible(
      find.text('Instagram'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.textContaining('Screen time'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('Main Today card shows a screen-time line', (tester) async {
    final repo = ScreenTimeRepository(
      db,
      _FakeSource(
        granted: true,
        raw: {
          'com.x': const AppUsage(
            packageName: 'com.x',
            label: 'X',
            foregroundMinutes: 90,
          ),
        },
      ),
    );
    await repo.sync(day: DateTime.now());

    await pump(tester, const HomePage(), _FakeSource(granted: true));
    expect(find.text('Screen time'), findsOneWidget);
    expect(find.textContaining('1h 30m'), findsWidgets);
    await closeApp(tester);
  });

  test('formatMinutes', () {
    expect(formatMinutes(0), '0m');
    expect(formatMinutes(45), '45m');
    expect(formatMinutes(90), '1h 30m');
    expect(formatMinutes(192), '3h 12m');
  });
}
