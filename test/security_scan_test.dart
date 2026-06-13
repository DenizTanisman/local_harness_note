import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// CR3-P7 / §14 security guardrails (static scan of lib/).
void main() {
  Iterable<File> dartFiles() => Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'));

  test('no raw print() anywhere (use nothing; never leak values)', () {
    final offenders = <String>[];
    for (final f in dartFiles()) {
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        // Allow debugPrint; forbid bare print(.
        final line = lines[i];
        if (RegExp(r'(^|[^a-zA-Z.])print\(').hasMatch(line)) {
          offenders.add('${f.path}:${i + 1}');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('no health/finance values written to logs or analytics (§14)', () {
    // Forbid logging that interpolates a sensitive value. We look for
    // debugPrint/log/analytics lines mentioning value-bearing identifiers.
    final sensitive = RegExp(
      r'(debugPrint|log|analytics)\b.*\$(kcal|weight|weightKg|bodyFat|'
      r'restingHr|hr|amount|intake|kg|bmi|bmr|tdee)',
      caseSensitive: false,
    );
    final offenders = <String>[];
    for (final f in dartFiles()) {
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (sensitive.hasMatch(lines[i])) offenders.add('${f.path}:${i + 1}');
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('manifest keeps FLAG_SECURE channel + no SCHEDULE_EXACT_ALARM', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('POST_NOTIFICATIONS'));
    expect(
      manifest,
      isNot(contains('android.permission.SCHEDULE_EXACT_ALARM')),
    );
    // FLAG_SECURE is applied via a MethodChannel from MainActivity.
    final mainActivity = File(
      'android/app/src/main/kotlin/dev/deniz/daily_tracker/MainActivity.kt',
    ).readAsStringSync();
    expect(mainActivity, contains('FLAG_SECURE'));
    expect(mainActivity, contains('daily_tracker/secure_window'));
  });
}
