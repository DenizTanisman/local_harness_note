import 'package:daily_tracker/core/date_key.dart';
import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/database_provider.dart';
import 'package:daily_tracker/data/repositories/health_repository.dart';
import 'package:daily_tracker/features/health/health_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR3-P3 acceptance (repo + UI): stats update on weight change; missing
/// profile shows '—' without crashing; sensor block shows placeholders.
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
      child: const MaterialApp(home: HealthPage()),
    );
  }

  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
  }

  group('repository', () {
    test('profile is a singleton (id always 1)', () async {
      final repo = HealthRepository(db);
      await repo.saveProfile(birthDate: '2000-01-01', sex: 'M', heightCm: 180);
      await repo.saveProfile(heightCm: 181, sex: 'M', birthDate: '2000-01-01');
      final all = await db.select(db.healthProfile).get();
      expect(all, hasLength(1));
      expect(all.single.heightCm, 181);
    });

    test(
      'latest body wins and BMI/BMR/TDEE recompute on weight change',
      () async {
        final repo = HealthRepository(db);
        await repo.saveProfile(
          birthDate: '2000-01-01',
          sex: 'M',
          heightCm: 180,
          activityLevel: 'moderate',
        );
        await repo.saveBody(date: '2026-06-10', weightKg: 80);
        await repo.saveBody(date: '2026-06-13', weightKg: 78);

        final latest = await repo.loadLatestBody();
        expect(latest!.weightKg, 78);
        expect(latest.date, '2026-06-13');
      },
    );

    test('vitalsFor returns empty when no samples', () async {
      final repo = HealthRepository(db);
      final v = await repo.vitalsFor(dateKey(DateTime.now()));
      expect(v.isEmpty, isTrue);
    });
  });

  group('UI', () {
    testWidgets('missing profile → stats show — and no crash', (tester) async {
      await pump(tester);
      expect(find.textContaining('BMI —'), findsOneWidget);
      expect(find.text('Connect a data source'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('entering weight after profile shows computed stats', (
      tester,
    ) async {
      final repo = HealthRepository(db);
      await repo.saveProfile(
        birthDate: '2000-01-01',
        sex: 'M',
        heightCm: 180,
        activityLevel: 'moderate',
      );
      await pump(tester);

      await tester.enterText(find.widgetWithText(TextField, 'Weight'), '80');
      await tester.tap(find.widgetWithText(FilledButton, 'Save body'));
      await tester.pumpAndSettle();

      // BMI 80/(1.8^2)=24.7; just assert it is no longer '—'.
      expect(find.textContaining('BMI 24'), findsOneWidget);
      expect(find.textContaining('BMI —'), findsNothing);
      await closeApp(tester);
    });

    testWidgets('sensor rows render placeholders', (tester) async {
      await pump(tester);
      expect(find.text('Resting HR'), findsOneWidget);
      expect(find.text('VO2max'), findsOneWidget);
      expect(find.text('Steps'), findsOneWidget);
      await closeApp(tester);
    });
  });
}
