import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_key.dart';
import '../../data/db/database_provider.dart';
import '../../data/repositories/analysis_repository.dart';

final analysisRepositoryProvider = Provider<AnalysisRepository>(
  (ref) => AnalysisRepository(ref.watch(databaseProvider)),
);

/// Selected analysis date — defaults to yesterday, never in the future
/// (spec 6.3). Shared by analysis, detail and money pages.
class SelectedDateNotifier extends Notifier<String> {
  @override
  String build() => dateKey(DateTime.now().subtract(const Duration(days: 1)));

  void select(String date) {
    if (date.compareTo(dateKey(DateTime.now())) > 0) return; // future blocked
    state = date;
  }
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, String>(
  SelectedDateNotifier.new,
);

/// Per-metric data floor: the first day a metric has meaningful data, so
/// the heatmap doesn't invent zero-history before tracking began. Temporary
/// ("şimdilik") — Money tracked since 15 Apr 2026, everything else since
/// 13 Jun 2026.
String heatmapDataFloor(String metricKey) =>
    metricKey == 'money' ? '2026-04-15' : '2026-06-13';

/// The heatmap shows exactly one calendar month — the month of the selected
/// date (1..N), instead of a rolling window.
final heatmapProvider = StreamProvider<HeatmapMatrix>((ref) {
  final date = ref.watch(selectedDateProvider);
  final parts = date.substring(0, 7).split('-').map(int.parse).toList();
  final daysInMonth = DateTime(parts[0], parts[1] + 1, 0).day;
  final endDate =
      '${date.substring(0, 7)}-${daysInMonth.toString().padLeft(2, '0')}';
  return ref
      .watch(analysisRepositoryProvider)
      .watchHeatmap(
        endDate,
        daysInMonth,
        floorFor: heatmapDataFloor,
        todayKey: dateKey(DateTime.now()),
      );
});

final breakdownProvider = StreamProvider<List<BreakdownNode>>((ref) {
  final date = ref.watch(selectedDateProvider);
  return ref.watch(analysisRepositoryProvider).watchBreakdown(date);
});
