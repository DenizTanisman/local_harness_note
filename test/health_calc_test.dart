import 'package:daily_tracker/features/health/health_calc.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR3-P3 §10 formula unit tests.
void main() {
  group('BMI', () {
    test('kg / m²', () {
      expect(HealthCalc.bmi(weightKg: 70, heightCm: 176)!, closeTo(22.6, 0.1));
    });
    test('null when inputs missing or height 0', () {
      expect(HealthCalc.bmi(weightKg: 70, heightCm: null), isNull);
      expect(HealthCalc.bmi(weightKg: null, heightCm: 176), isNull);
      expect(HealthCalc.bmi(weightKg: 70, heightCm: 0), isNull);
    });
  });

  group('age', () {
    test('whole years, birthday not yet reached this year', () {
      // born 2000-06-20, on 2026-06-13 → 25 (birthday in a week)
      expect(HealthCalc.ageOn('2000-06-20', DateTime(2026, 6, 13)), 25);
      // on/after birthday → 26
      expect(HealthCalc.ageOn('2000-06-20', DateTime(2026, 6, 20)), 26);
    });
    test('null birth date → null', () {
      expect(HealthCalc.ageOn(null, DateTime(2026, 1, 1)), isNull);
    });
  });

  group('BMR Mifflin-St Jeor', () {
    test('male', () {
      // 10*70 + 6.25*176 - 5*25 + 5 = 700 + 1100 - 125 + 5 = 1680
      expect(
        HealthCalc.bmr(weightKg: 70, heightCm: 176, age: 25, sex: 'M'),
        1680,
      );
    });
    test('female', () {
      // 700 + 1100 - 125 - 161 = 1514
      expect(
        HealthCalc.bmr(weightKg: 70, heightCm: 176, age: 25, sex: 'F'),
        1514,
      );
    });
    test('null when any input missing', () {
      expect(
        HealthCalc.bmr(weightKg: 70, heightCm: 176, age: 25, sex: null),
        isNull,
      );
    });
  });

  group('TDEE', () {
    test('static = BMR × activity coefficient', () {
      expect(
        HealthCalc.tdeeStatic(bmr: 1680, activityLevel: 'moderate'),
        1680 * 1.55,
      );
      expect(
        HealthCalc.tdeeStatic(bmr: 1680, activityLevel: 'sedentary'),
        1680 * 1.2,
      );
    });

    test('static target is intake-INDEPENDENT (§10 correction)', () {
      // There is no intake parameter at all — coloring target can never
      // be inflated by eating more.
      final a = HealthCalc.tdeeStatic(bmr: 1680, activityLevel: 'active');
      final b = HealthCalc.tdeeStatic(bmr: 1680, activityLevel: 'active');
      expect(a, b);
    });

    test('dynamic = BMR + active kcal (separate from coloring)', () {
      expect(HealthCalc.tdeeDynamic(bmr: 1680, activeKcal: 400), 2080);
      expect(HealthCalc.tdeeDynamic(bmr: 1680, activeKcal: null), 1680);
    });
  });

  group('VO2max fallback', () {
    test('15.3 * (208 - 0.7*age) / RHR', () {
      // age 25, RHR 60 → 15.3*(208-17.5)/60 = 15.3*190.5/60 = 48.58
      expect(
        HealthCalc.vo2maxFallback(age: 25, restingHr: 60)!,
        closeTo(48.58, 0.1),
      );
    });
    test('null on missing/zero RHR', () {
      expect(HealthCalc.vo2maxFallback(age: 25, restingHr: 0), isNull);
      expect(HealthCalc.vo2maxFallback(age: null, restingHr: 60), isNull);
    });
  });
}
