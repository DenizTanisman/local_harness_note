import 'dart:io';

import 'package:local_harness_not/theme/app_tokens.dart';
import 'package:local_harness_not/theme/heat_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR1-B acceptance: every raw color lives in lib/theme/; heatmap bucket
/// colors are untouched data colors; no BackdropFilter anywhere.
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

  test('heatmap bucket palette is byte-identical to the spec values', () {
    // CR1-B rule 2: bucket colors carry data meaning and must not follow
    // the theme.
    const expected = {
      'black': Color(0xFF11151C),
      'white': Color(0xFFE6EDF3),
      'lightBlue': Color(0xFF56CCF2),
      'blue': Color(0xFF2F81F7),
      'darkBlue': Color(0xFF1E40AF),
      'lightYellow': Color(0xFFF8E3A1),
      'yellow': Color(0xFFD4A72C),
      'darkYellow': Color(0xFF9E6A03),
      'lightGreen': Color(0xFF56D364),
      'green': Color(0xFF2EA043),
      'darkGreen': Color(0xFF196C2E),
      'orange': Color(0xFFDB6D28),
      'lightPink': Color(0xFFF9A8D4),
      'pink': Color(0xFFEC4899),
      'darkPink': Color(0xFFBE185D),
      'red': Color(0xFFDA3633),
    };
    expect(HeatColors.palette, expected);
  });

  test('sparkline stays GitHub green, not theme blue (CR1-B rule 3)', () {
    expect(AppTokens.sparkline, const Color(0xFF39D353));
    expect(AppTokens.sparkline, isNot(AppTokens.accentStart));
  });
}
