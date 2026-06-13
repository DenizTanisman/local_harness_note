import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_key.dart';
import '../../data/db/app_database.dart';
import '../../data/db/database_provider.dart';
import '../../data/repositories/sport_repository.dart';

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

final calorieEntriesTodayProvider = StreamProvider<List<CalorieEntry>>(
  (ref) => ref
      .watch(sportRepositoryProvider)
      .watchCalorieEntries(dateKey(DateTime.now())),
);

/// The month shown by the Sport sparklines (current month).
final sportMonthProvider = Provider<String>(
  (ref) => dateKey(DateTime.now()).substring(0, 7),
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
