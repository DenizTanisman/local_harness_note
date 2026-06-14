import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_key.dart';
import '../../data/db/app_database.dart';
import '../../data/db/database_provider.dart';
import '../../data/repositories/sport_repository.dart';
import '../home/home_providers.dart';

final sportRepositoryProvider = Provider<SportRepository>(
  (ref) => SportRepository(ref.watch(databaseProvider)),
);

final programsProvider = StreamProvider<List<Program>>(
  (ref) => ref.watch(sportRepositoryProvider).watchPrograms(),
);

final exerciseTitlesProvider = StreamProvider<List<String>>(
  (ref) => ref.watch(sportRepositoryProvider).watchExerciseTitles(),
);

final foodTypesProvider = StreamProvider<List<String>>(
  (ref) => ref.watch(sportRepositoryProvider).watchFoodTypes(),
);

/// Saved foods with their category + per-unit calories (grouped picker).
final foodsProvider = StreamProvider<List<SavedFoodType>>(
  (ref) => ref.watch(sportRepositoryProvider).watchFoods(),
);

/// Fixed categories for the calorie picker (calorie redesign).
const calorieCategories = [
  'Fruit',
  'Vegetable',
  'HealthyMeal',
  'FastFood',
  'Drink',
  'Snack',
];

final calorieEntriesTodayProvider = StreamProvider<List<CalorieEntry>>(
  (ref) => ref
      .watch(sportRepositoryProvider)
      .watchCalorieEntries(dateKey(DateTime.now())),
);

/// The month shown by the Sport sparklines (CR-3 follow-up #5) — the month
/// of the shared selected day, so ‹ › keep every page in sync.
class SportMonthNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(homeDateProvider).substring(0, 7);

  void shift(int months) =>
      ref.read(homeDateProvider.notifier).shiftMonths(months);

  void reset() => ref.read(homeDateProvider.notifier).resetToToday();
}

final sportMonthProvider = NotifierProvider<SportMonthNotifier, String>(
  SportMonthNotifier.new,
);

/// Day-of-month → calorie_day for the sport month (intake + frozen color).
final calorieMonthProvider = StreamProvider<Map<int, CalorieDayData>>(
  (ref) => ref
      .watch(sportRepositoryProvider)
      .watchCalorieMonth(ref.watch(sportMonthProvider)),
);

/// Day-of-month → (volume, programId) for the sport month.
final programMonthProvider =
    StreamProvider<Map<int, ({double volume, int programId})>>(
      (ref) => ref
          .watch(sportRepositoryProvider)
          .watchProgramMonth(ref.watch(sportMonthProvider)),
    );
