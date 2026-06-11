import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/repositories/money_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 5 acceptance (repository level): budget formula, subtype
/// breakdown, monthly table density, reminders.
void main() {
  late AppDatabase db;
  late MoneyRepository money;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    money = MoneyRepository(db);
  });
  tearDown(() => db.close());

  group('red/green budget formula (spec 6.5)', () {
    test('income 15000, essential 10500, 30 days → budget 150; lux 200 → red',
        () async {
      // June 2026 has 30 days. Rent+Bill are seeded essential.
      await money.addTransaction(
          date: '2026-06-01',
          direction: 'income',
          amount: 15000,
          category: 'Scholarship');
      await money.addTransaction(
          date: '2026-06-02',
          direction: 'outcome',
          amount: 8000,
          category: 'Rent');
      await money.addTransaction(
          date: '2026-06-03',
          direction: 'outcome',
          amount: 2500,
          category: 'Bill');
      // Day with 200 luxury (Food is non-essential).
      await money.addTransaction(
          date: '2026-06-10',
          direction: 'outcome',
          amount: 200,
          category: 'Food');
      // Day with 100 luxury → green.
      await money.addTransaction(
          date: '2026-06-11',
          direction: 'outcome',
          amount: 100,
          category: 'Entertainment');

      final general = await money.loadGeneral('2026-06');
      expect(general.dailyBudget, 150); // (15000 − 10500) / 30
      expect(general.days[10]!.overBudget, isTrue);
      expect(general.days[11]!.overBudget, isFalse);
      // Essential-only days carry zero luxury → green.
      expect(general.days[2]!.luxury, 0);
      expect(general.days[2]!.overBudget, isFalse);
    });
  });

  group('category/subtype breakdown (spec §9.2)', () {
    test('Bill (home) + Bill (phone) roll up under Bill', () async {
      await money.addTransaction(
          date: '2026-06-05',
          direction: 'outcome',
          amount: 2000,
          category: 'Bill',
          subtype: 'home');
      await money.addTransaction(
          date: '2026-06-06',
          direction: 'outcome',
          amount: 500,
          category: 'Bill',
          subtype: 'phone');
      await money.addTransaction(
          date: '2026-06-07',
          direction: 'outcome',
          amount: 300,
          category: 'Food');

      final general = await money.loadGeneral('2026-06');
      final bill = general.outcome.firstWhere((c) => c.name == 'Bill');
      expect(bill.total, 2500); // GROUP BY category
      expect(
        bill.subtypes.map((s) => '${s.label}=${s.total}'),
        unorderedEquals(['Bill (home)=2000.0', 'Bill (phone)=500.0']),
      );
      final food = general.outcome.firstWhere((c) => c.name == 'Food');
      expect(food.subtypes, isEmpty);
    });

    test('displayCategory never string-parses', () async {
      final id = await money.addTransaction(
          date: '2026-06-05',
          direction: 'outcome',
          amount: 10,
          category: 'Bill',
          subtype: 'home');
      final tx = await (db.select(db.transactions)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      expect(displayCategory(tx), 'Bill (home)');
      expect(tx.category, 'Bill');
      expect(tx.subtype, 'home');
    });
  });

  group('monthly table (spec 6.5)', () {
    test('dates without entries are skipped; N entries span N rows',
        () async {
      await money.addTransaction(
          date: '2026-06-05',
          direction: 'outcome',
          amount: 100,
          category: 'Food');
      await money.addTransaction(
          date: '2026-06-05',
          direction: 'outcome',
          amount: 50,
          category: 'Entertainment');
      await money.addTransaction(
          date: '2026-06-05',
          direction: 'income',
          amount: 15000,
          category: 'Scholarship');
      await money.addTransaction(
          date: '2026-06-20',
          direction: 'outcome',
          amount: 75,
          category: 'Food');

      final rows = await money.loadMonthlyTable('2026-06');
      // 06-05: max(1 income, 2 outcome) = 2 rows; 06-20: 1 row.
      expect(rows, hasLength(3));
      expect(rows.where((r) => r.date == '2026-06-05'), hasLength(2));
      expect(rows.first.income!.category, 'Scholarship');
      expect(rows[1].income, isNull); // second row has no income entry
      expect(rows[2].date, '2026-06-20');
      // No row for any other date of the month.
      expect(rows.map((r) => r.date).toSet(), {'2026-06-05', '2026-06-20'});
    });
  });

  group('reminders (spec 6.2)', () {
    test('outcome offsets queue reminder rows dated before the transaction',
        () async {
      final id = await money.addTransaction(
        date: '2026-06-15',
        direction: 'outcome',
        amount: 2500,
        category: 'Bill',
        reminderOffsets: [0, 2],
      );
      final reminders = await (db.select(db.expenseReminders)
            ..where((r) => r.transactionId.equals(id)))
          .get();
      expect(reminders.map((r) => r.remindDate),
          unorderedEquals(['2026-06-15', '2026-06-13']));
      expect(reminders.every((r) => !r.fired), isTrue);
    });

    test('income never queues reminders', () async {
      await money.addTransaction(
        date: '2026-06-15',
        direction: 'income',
        amount: 100,
        category: 'Scholarship',
        reminderOffsets: [1],
      );
      expect(await db.select(db.expenseReminders).get(), isEmpty);
    });

    test('deleting a transaction cascades its reminders', () async {
      final id = await money.addTransaction(
        date: '2026-06-15',
        direction: 'outcome',
        amount: 10,
        category: 'Food',
        reminderOffsets: [1],
      );
      await money.deleteTransaction(id);
      expect(await db.select(db.expenseReminders).get(), isEmpty);
    });
  });

  group('categories', () {
    test('addCategory appends and duplicate names are ignored', () async {
      await money.addCategory('outcome', 'Transport');
      await money.addCategory('outcome', 'Transport'); // UNIQUE(direction,name)
      final all = await (db.select(db.moneyCategories)
            ..where((c) => c.name.equals('Transport')))
          .get();
      expect(all, hasLength(1));
    });
  });
}
