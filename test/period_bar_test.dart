import 'package:local_harness_not/features/shared/period_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR-3 follow-up #5: the unified date/month component behaves the same
/// everywhere it's used.
void main() {
  Widget host(PeriodBar bar) => MaterialApp(home: Scaffold(body: bar));

  testWidgets('prev/next/reset/label callbacks fire', (tester) async {
    var prev = 0, next = 0, reset = 0, label = 0;
    await tester.pumpWidget(
      host(
        PeriodBar(
          label: '2026-06',
          highlighted: true,
          onReset: () => reset++,
          resetLabel: 'This month',
          onPrev: () => prev++,
          onNext: () => next++,
          onTapLabel: () => label++,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('period-prev')));
    await tester.tap(find.byKey(const ValueKey('period-next')));
    await tester.tap(find.byKey(const ValueKey('period-label')));
    await tester.tap(find.byKey(const ValueKey('period-reset')));
    expect([prev, next, label, reset], [1, 1, 1, 1]);
    expect(find.text('This month'), findsOneWidget);
  });

  testWidgets('next disabled when canGoNext is false; no reset when not '
      'highlighted', (tester) async {
    var next = 0;
    await tester.pumpWidget(
      host(
        PeriodBar(
          label: '2026-06-13',
          canGoNext: false,
          highlighted: false,
          onReset: () {},
          onPrev: () {},
          onNext: () => next++,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('period-next')));
    expect(next, 0); // disabled
    expect(find.byKey(const ValueKey('period-reset')), findsNothing);
  });
}
