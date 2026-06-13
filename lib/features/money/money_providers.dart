import 'package:flutter_riverpod/flutter_riverpod.dart';

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
