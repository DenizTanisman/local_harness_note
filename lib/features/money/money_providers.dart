import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_key.dart';
import '../../data/db/app_database.dart';
import '../../data/db/database_provider.dart';
import '../../data/repositories/money_repository.dart';
import '../analysis/analysis_providers.dart';

final moneyRepositoryProvider = Provider<MoneyRepository>(
  (ref) => MoneyRepository(ref.watch(databaseProvider)),
);

final moneyCategoriesProvider =
    StreamProvider.family<List<MoneyCategory>, String>(
      (ref, direction) =>
          ref.watch(moneyRepositoryProvider).watchCategories(direction),
    );

/// General view for the month of the selected date.
final moneyGeneralProvider = StreamProvider<MoneyGeneral>((ref) {
  final month = ref.watch(selectedDateProvider).substring(0, 7);
  return ref.watch(moneyRepositoryProvider).watchGeneral(month);
});

final monthlyTableProvider = StreamProvider<List<MonthlyTableRow>>((ref) {
  final month = ref.watch(selectedDateProvider).substring(0, 7);
  return ref.watch(moneyRepositoryProvider).watchMonthlyTable(month);
});

/// General view for an explicit 'YYYY-MM' — used by the Money tab and the
/// Main balance card so they aren't tied to the Analysis date.
final moneyGeneralByMonthProvider = StreamProvider.family<MoneyGeneral, String>(
  (ref, month) => ref.watch(moneyRepositoryProvider).watchGeneral(month),
);

/// Net income − outcome for [month] ('YYYY-MM').
double monthBalance(MoneyGeneral general) {
  final income = general.income.fold<double>(0, (a, c) => a + c.total);
  final outcome = general.outcome.fold<double>(0, (a, c) => a + c.total);
  return income - outcome;
}

/// The month shown in the Money tab (CR-3 §4) — own state, not the
/// Analysis date. Defaults to the current month; ‹ › step it.
class MoneyMonthNotifier extends Notifier<String> {
  @override
  String build() => dateKey(DateTime.now()).substring(0, 7);

  void shift(int months) {
    final parts = state.split('-').map(int.parse).toList();
    final d = DateTime(parts[0], parts[1] + months, 1);
    state =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';
  }

  void reset() => state = dateKey(DateTime.now()).substring(0, 7);
}

/// Current month 'YYYY-MM' (for highlight/reset comparisons).
String currentMonth() => dateKey(DateTime.now()).substring(0, 7);

final moneyMonthProvider = NotifierProvider<MoneyMonthNotifier, String>(
  MoneyMonthNotifier.new,
);

/// Total outcome for a given day (Daily Check-in read-only summary).
final dayOutcomeProvider = StreamProvider.family<double, String>(
  (ref, date) => ref.watch(moneyRepositoryProvider).watchDayOutcome(date),
);

/// One day's transactions — the editable breakdown under the money form.
final dayTransactionsProvider = StreamProvider.family<List<Transaction>, String>(
  (ref, date) => ref.watch(moneyRepositoryProvider).watchDayTransactions(date),
);

/// Monthly table (income | date | outcome) for the Money tab's month.
final moneyTabTableProvider = StreamProvider<List<MonthlyTableRow>>((ref) {
  return ref
      .watch(moneyRepositoryProvider)
      .watchMonthlyTable(ref.watch(moneyMonthProvider));
});

/// Money-tab transaction list (newest first).
final moneyTabTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return ref
      .watch(moneyRepositoryProvider)
      .watchTransactions(ref.watch(moneyMonthProvider));
});

/// All money categories (both directions) for the Categories sub-tab.
final allMoneyCategoriesProvider = StreamProvider<List<MoneyCategory>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.moneyCategories)
    ..orderBy([
      (c) => OrderingTerm.asc(c.direction),
      (c) => OrderingTerm.asc(c.sortOrder),
    ]);
  return query.watch();
});
