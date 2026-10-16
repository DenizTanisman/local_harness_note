import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// CR1-B acceptance: every raw color lives in lib/theme/; no BackdropFilter
/// anywhere.
void main() {
  test('no raw Color(0x...) outside lib/theme/', () {
    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.contains('lib/theme/')) continue;
      if (entity.path.endsWith('.g.dart')) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('Color(0x')) {
          offenders.add('${entity.path}:${i + 1}');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason: 'raw colors must move to AppTokens:\n${offenders.join('\n')}',
    );
  });

  test('no BackdropFilter in the app (scroll performance rule)', () {
    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      // Constructor usage only — docs may mention the rule by name.
      if (entity.readAsStringSync().contains('BackdropFilter(')) {
        offenders.add(entity.path);
      }
    }
    expect(offenders, isEmpty);
  });
}
