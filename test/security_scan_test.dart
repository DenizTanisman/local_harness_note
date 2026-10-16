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

  test('note contents never written to logs', () {
    // Forbid logging that interpolates note text or tool payloads.
    final sensitive = RegExp(
      r'(debugPrint|log)\b.*\$\{?(body|text|note|args|result|payload|'
      r'prompt|token|secret|config)',
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
      'android/app/src/main/kotlin/dev/deniz/local_harness_not/MainActivity.kt',
    ).readAsStringSync();
    expect(mainActivity, contains('FLAG_SECURE'));
    expect(mainActivity, contains('local_harness_not/secure_window'));
  });

  test('split app sheds the monolith collection permissions', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    for (final gone in [
      'PACKAGE_USAGE_STATS',
      'QUERY_ALL_PACKAGES',
      'android.permission.health.',
      'com.google.android.apps.healthdata',
    ]) {
      expect(manifest, isNot(contains(gone)), reason: gone);
    }
  });

  test('hub provider is signature-guarded, also inside call()', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('android:protectionLevel="signature"'));
    expect(manifest, contains('dev.deniz.local_harness_not.hub'));
    final provider = File(
      'android/app/src/main/kotlin/dev/deniz/local_harness_not/HubProvider.kt',
    ).readAsStringSync();
    expect(provider, contains('checkCallingPermission(HUB_PERMISSION)'));
    expect(provider, contains('throw SecurityException'));
    final mainActivity = File(
      'android/app/src/main/kotlin/dev/deniz/local_harness_not/MainActivity.kt',
    ).readAsStringSync();
    expect(mainActivity, contains('"local_harness/hub"'));
    expect(mainActivity, contains('ATOMIC_MOVE'));
  });
}
