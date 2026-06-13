import '../../core/date_key.dart';

/// Activity multipliers for TDEE (CR-3 §10).
const activityCoefficients = <String, double>{
  'sedentary': 1.2,
  'light': 1.375,
  'moderate': 1.55,
  'active': 1.725,
  'very': 1.9,
};

const activityLevels = ['sedentary', 'light', 'moderate', 'active', 'very'];

/// Pure body/health calculations (CR-3 §10). All inputs explicit so the
/// formulas are unit-testable without any device or clock.
class HealthCalc {
  HealthCalc._();

  /// kg / m². Returns null if inputs are missing/invalid.
  static double? bmi({double? weightKg, double? heightCm}) {
    if (weightKg == null || heightCm == null || heightCm <= 0) return null;
    final m = heightCm / 100;
    return weightKg / (m * m);
  }

  /// Whole years between [birthDate] ('YYYY-MM-DD') and [on].
  static int? ageOn(String? birthDate, DateTime on) {
    if (birthDate == null) return null;
    final b = parseDateKey(birthDate);
    var age = on.year - b.year;
    if (on.month < b.month || (on.month == b.month && on.day < b.day)) {
      age--;
    }
    return age < 0 ? null : age;
  }

  /// Mifflin-St Jeor BMR. [sex] is 'M' or 'F'.
  static double? bmr({
    double? weightKg,
    double? heightCm,
    int? age,
    String? sex,
  }) {
    if (weightKg == null || heightCm == null || age == null || sex == null) {
      return null;
    }
    final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
    return sex == 'M' ? base + 5 : base - 161;
  }

  /// Static TDEE = BMR × activity coefficient. This is the calorie target
  /// used for sparkline coloring (CR-3 §10/§11 — NOT intake-dependent).
  static double? tdeeStatic({double? bmr, String? activityLevel}) {
    if (bmr == null || activityLevel == null) return null;
    final coef = activityCoefficients[activityLevel];
    if (coef == null) return null;
    return bmr * coef;
  }

  /// "Live" expenditure indicator = BMR + active kcal burned. Kept separate
  /// from the coloring target (CR-3 §10 correction).
  static double? tdeeDynamic({double? bmr, double? activeKcal}) {
    if (bmr == null) return null;
    return bmr + (activeKcal ?? 0);
  }

  /// VO2max fallback estimate from resting heart rate (CR-3 §10).
  static double? vo2maxFallback({int? age, double? restingHr}) {
    if (age == null || restingHr == null || restingHr <= 0) return null;
    return 15.3 * (208 - 0.7 * age) / restingHr;
  }
}
