import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_key.dart';
import '../../data/db/app_database.dart';
import '../../data/db/database_provider.dart';
import '../../data/repositories/health_repository.dart';
import 'health_calc.dart';

final healthRepositoryProvider = Provider<HealthRepository>(
  (ref) => HealthRepository(ref.watch(databaseProvider)),
);

final healthProfileProvider = StreamProvider<HealthProfileData?>(
  (ref) => ref.watch(healthRepositoryProvider).watchProfile(),
);

final latestBodyProvider = StreamProvider<BodyLogData?>(
  (ref) => ref.watch(healthRepositoryProvider).watchLatestBody(),
);

/// Today's vitals (placeholder until a HealthSource is wired, P4).
final todayVitalsProvider = StreamProvider<DailyVitals>(
  (ref) =>
      ref.watch(healthRepositoryProvider).watchVitals(dateKey(DateTime.now())),
);

/// BMI / BMR / static TDEE derived from the profile + latest body (§10).
/// Any missing input yields null fields (UI shows '—').
final bodyStatsProvider = Provider<BodyStats>((ref) {
  final profile = ref.watch(healthProfileProvider).value;
  final body = ref.watch(latestBodyProvider).value;
  final age = HealthCalc.ageOn(profile?.birthDate, DateTime.now());
  final bmi = HealthCalc.bmi(
    weightKg: body?.weightKg,
    heightCm: profile?.heightCm,
  );
  final bmr = HealthCalc.bmr(
    weightKg: body?.weightKg,
    heightCm: profile?.heightCm,
    age: age,
    sex: profile?.sex,
  );
  final tdee = HealthCalc.tdeeStatic(
    bmr: bmr,
    activityLevel: profile?.activityLevel,
  );
  return BodyStats(bmi: bmi, bmr: bmr, tdeeStatic: tdee);
});
