import 'package:daily_tracker/core/date_key.dart';
import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/database_provider.dart';
import 'package:daily_tracker/data/repositories/money_repository.dart';
import 'package:daily_tracker/features/money/day_money_editor.dart';
import 'package:daily_tracker/features/money/money_reveal.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Privacy: money amounts are masked as *** until the password is entered,
/// scoped to one spot or all, and reset every time the app leaves the
/// foreground.
void main() {
  group('MoneyRevealNotifier', () {
    test('starts masked; revealOne is per-id; revealAll covers everything', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(moneyRevealProvider.notifier);

      expect(container.read(moneyRevealProvider).shows('a'), isFalse);

      notifier.revealOne('a');
      expect(container.read(moneyRevealProvider).shows('a'), isTrue);
      expect(container.read(moneyRevealProvider).shows('b'), isFalse);

      notifier.revealAll();
      expect(container.read(moneyRevealProvider).shows('b'), isTrue);

      notifier.reset();
      expect(container.read(moneyRevealProvider).shows('a'), isFalse);
    });
  });

  group('DayMoneyEditor masking', () {
    late AppDatabase db;
    late ProviderContainer container;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    testWidgets('amounts render as *** by default', (tester) async {
      final today = dateKey(DateTime.now());
      await MoneyRepository(db).addTransaction(
        date: today,
        direction: 'outcome',
        amount: 100,
        category: 'Food',
      );

      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(body: DayMoneyEditor(date: today)),
          ),
        ),
      );
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('Outcome: ***'), findsOneWidget);
      expect(find.text('Outcome: 100 ₺'), findsNothing);

      // Clean teardown (drift stream subscription).
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
