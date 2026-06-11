import 'package:drift/drift.dart';

import '../../core/date_key.dart';
import '../db/app_database.dart';

/// One sparkline day on the Money General page (spec 6.5).
class MoneyDayPoint {
  const MoneyDayPoint({required this.luxury, required this.overBudget});

  /// Sum of non-essential outcome that day.
  final double luxury;

  /// luxury > dailyBudget → red dot, else green.
  final bool overBudget;
}

class CategoryTotal {
  const CategoryTotal({
    required this.name,
    required this.total,
    this.subtypes = const [],
  });

  final String name;
  final double total;

  /// 'Bill (home)' style breakdown — only subtyped rows appear here;
  /// totals are always per category (spec §9.2).
  final List<({String label, double total})> subtypes;
}

class MoneyGeneral {
  const MoneyGeneral({
    required this.dailyBudget,
    required this.days,
    required this.income,
    required this.outcome,
  });

  /// (month income − month essential outcome) / days in month.
  final double dailyBudget;

  /// Day of month → point; days without any outcome are absent.
  final Map<int, MoneyDayPoint> days;

  final List<CategoryTotal> income;
  final List<CategoryTotal> outcome;
}

/// One visual row of the Monthly table (spec 6.5): income on the left,
/// date in the middle, outcome on the right.
class MonthlyTableRow {
  const MonthlyTableRow({required this.date, this.income, this.outcome});

  final String date;
  final Transaction? income;
  final Transaction? outcome;
}

class MoneyRepository {
  MoneyRepository(this.db);

  final AppDatabase db;

  Stream<void> changes() => db
      .customSelect(
        'SELECT 1',
        readsFrom: {db.transactions, db.moneyCategories, db.expenseReminders},
      )
      .watch()
      .map((_) {});

  // ---------- categories ----------

  Stream<List<MoneyCategory>> watchCategories(String direction) {
    final query = db.select(db.moneyCategories)
      ..where((c) => c.direction.equals(direction))
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]);
    return query.watch();
  }

  Future<int> addCategory(String direction, String name) async {
    final max = db.moneyCategories.sortOrder.max();
    final row = await (db.selectOnly(
      db.moneyCategories,
    )..addColumns([max])).getSingle();
    return db
        .into(db.moneyCategories)
        .insert(
          MoneyCategoriesCompanion.insert(
            direction: direction,
            name: name.trim(),
            sortOrder: Value((row.read(max) ?? 0) + 1),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  // ---------- transactions ----------

  /// Saves a transaction; for outcomes, [reminderOffsets] (days before the
  /// transaction date, 0–3 each) queue local reminders (spec 6.2).
  Future<int> addTransaction({
    required String date,
    required String direction,
    required double amount,
    required String category,
    String? subtype,
    String? note,
    List<int> reminderOffsets = const [],
  }) {
    return db.transaction(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              date: date,
              direction: direction,
              amount: amount,
              category: category,
              subtype: Value(_clean(subtype)),
              note: Value(_clean(note)),
              createdAt: now,
              updatedAt: now,
            ),
          );
      if (direction == 'outcome') {
        final today = dateKey(DateTime.now());
        for (final offset in reminderOffsets) {
          final remindDate = dateKey(
            parseDateKey(date).subtract(Duration(days: offset)),
          );
          // Past-day entries never queue reminders (CR1-D).
          if (remindDate.compareTo(today) < 0) continue;
          await db
              .into(db.expenseReminders)
              .insert(
                ExpenseRemindersCompanion.insert(
                  transactionId: id,
                  remindDate: remindDate,
                ),
              );
        }
      }
      return id;
    });
  }

  Future<void> updateTransaction(
    int id, {
    double? amount,
    String? category,
    String? subtype,
    String? note,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (db.update(db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        amount: amount != null ? Value(amount) : const Value.absent(),
        category: category != null ? Value(category) : const Value.absent(),
        subtype: Value(_clean(subtype)),
        note: Value(_clean(note)),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> deleteTransaction(int id) =>
      (db.delete(db.transactions)..where((t) => t.id.equals(id))).go();

  String? _clean(String? raw) {
    final trimmed = raw?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  // ---------- General view (spec 6.5) ----------

  Stream<MoneyGeneral> watchGeneral(String month) =>
      changes().asyncMap((_) => loadGeneral(month));

  Future<MoneyGeneral> loadGeneral(String month) async {
    final rows = await (db.select(
      db.transactions,
    )..where((t) => t.date.like('$month-%'))).get();
    final categories = await db.select(db.moneyCategories).get();
    final essential = {
      for (final c in categories)
        if (c.direction == 'outcome' && c.isEssential) c.name,
    };

    final parts = month.split('-').map(int.parse).toList();
    final daysInMonth = DateTime(parts[0], parts[1] + 1, 0).day;

    var monthIncome = 0.0;
    var monthEssential = 0.0;
    final luxuryByDay = <int, double>{};
    final outcomeDays = <int>{};
    for (final tx in rows) {
      final day = int.parse(tx.date.substring(8));
      if (tx.direction == 'income') {
        monthIncome += tx.amount;
        continue;
      }
      outcomeDays.add(day);
      if (essential.contains(tx.category)) {
        monthEssential += tx.amount;
      } else {
        luxuryByDay[day] = (luxuryByDay[day] ?? 0) + tx.amount;
      }
    }
    final dailyBudget = (monthIncome - monthEssential) / daysInMonth;

    final days = <int, MoneyDayPoint>{
      for (final day in outcomeDays)
        day: MoneyDayPoint(
          luxury: luxuryByDay[day] ?? 0,
          overBudget: (luxuryByDay[day] ?? 0) > dailyBudget,
        ),
    };

    return MoneyGeneral(
      dailyBudget: dailyBudget,
      days: days,
      income: _categoryTotals(rows, 'income'),
      outcome: _categoryTotals(rows, 'outcome'),
    );
  }

  List<CategoryTotal> _categoryTotals(
    List<Transaction> rows,
    String direction,
  ) {
    final byCategory = <String, double>{};
    final bySubtype = <String, Map<String, double>>{};
    for (final tx in rows.where((t) => t.direction == direction)) {
      byCategory[tx.category] = (byCategory[tx.category] ?? 0) + tx.amount;
      if (tx.subtype != null) {
        final subs = bySubtype.putIfAbsent(tx.category, () => {});
        subs[tx.subtype!] = (subs[tx.subtype!] ?? 0) + tx.amount;
      }
    }
    final names = byCategory.keys.toList()
      ..sort((a, b) => byCategory[b]!.compareTo(byCategory[a]!));
    return [
      for (final name in names)
        CategoryTotal(
          name: name,
          total: byCategory[name]!,
          subtypes: [
            for (final sub
                in (bySubtype[name] ?? const <String, double>{}).entries)
              (label: '$name (${sub.key})', total: sub.value),
          ],
        ),
    ];
  }

  // ---------- Monthly table (spec 6.5) ----------

  Stream<List<MonthlyTableRow>> watchMonthlyTable(String month) =>
      changes().asyncMap((_) => loadMonthlyTable(month));

  /// Dynamic rows: a date with N entries on one side spans N rows; dates
  /// with no entries at all do not appear.
  Future<List<MonthlyTableRow>> loadMonthlyTable(String month) async {
    final rows =
        await (db.select(db.transactions)
              ..where((t) => t.date.like('$month-%'))
              ..orderBy([
                (t) => OrderingTerm.asc(t.date),
                (t) => OrderingTerm.asc(t.createdAt),
              ]))
            .get();

    final byDate =
        <String, ({List<Transaction> income, List<Transaction> outcome})>{};
    for (final tx in rows) {
      final bucket = byDate.putIfAbsent(
        tx.date,
        () => (income: <Transaction>[], outcome: <Transaction>[]),
      );
      (tx.direction == 'income' ? bucket.income : bucket.outcome).add(tx);
    }

    final result = <MonthlyTableRow>[];
    for (final date in byDate.keys.toList()..sort()) {
      final bucket = byDate[date]!;
      final count = bucket.income.length > bucket.outcome.length
          ? bucket.income.length
          : bucket.outcome.length;
      for (var i = 0; i < count; i++) {
        result.add(
          MonthlyTableRow(
            date: date,
            income: i < bucket.income.length ? bucket.income[i] : null,
            outcome: i < bucket.outcome.length ? bucket.outcome[i] : null,
          ),
        );
      }
    }
    return result;
  }
}

/// 'Bill' or 'Bill (home)' display name (spec §9.2 — never string-parsed).
String displayCategory(Transaction tx) =>
    tx.subtype == null ? tx.category : '${tx.category} (${tx.subtype})';
