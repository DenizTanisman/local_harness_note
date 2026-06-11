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

/// Visible day window of the heatmap (scrollable, ends at selected date).
const heatmapWindowDays = 60;

final heatmapProvider = StreamProvider<HeatmapMatrix>((ref) {
  final date = ref.watch(selectedDateProvider);
  return ref
      .watch(analysisRepositoryProvider)
      .watchHeatmap(date, heatmapWindowDays);
});

final breakdownProvider = StreamProvider<List<BreakdownNode>>((ref) {
  final date = ref.watch(selectedDateProvider);
  return ref.watch(analysisRepositoryProvider).watchBreakdown(date);
});
