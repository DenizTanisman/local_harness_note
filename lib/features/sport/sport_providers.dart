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
