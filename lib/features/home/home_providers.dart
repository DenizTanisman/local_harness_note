import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_key.dart';
import '../../data/db/app_database.dart';
import '../../data/db/database_provider.dart';
import '../../data/repositories/entry_repository.dart';
import '../../data/repositories/tree_repository.dart';

final entryRepositoryProvider = Provider<EntryRepository>(
  (ref) => EntryRepository(ref.watch(databaseProvider)),
);

final treeRepositoryProvider = Provider<TreeRepository>(
  (ref) => TreeRepository(ref.watch(databaseProvider)),
);

/// True while a card is being long-press dragged — gap targets light up.
class DraggingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final draggingProvider = NotifierProvider<DraggingNotifier, bool>(
  DraggingNotifier.new,
);

/// Active write date of the home page (CR1-D): defaults to today, may be
/// moved to any PAST day; the future stays blocked. Never persisted —
/// every app start and notification tap resets to today.
class ActiveWriteDateNotifier extends Notifier<String> {
  @override
  String build() => dateKey(DateTime.now());

  void select(String date) {
    if (date.compareTo(dateKey(DateTime.now())) > 0) return;
    state = date;
  }

  /// Move the selected day by whole months, keeping the day-of-month (clamped
  /// to the target month's length). The future stays blocked.
  void shiftMonths(int months) {
    final parts = state.split('-').map(int.parse).toList();
    final targetLen = DateTime(parts[0], parts[1] + months + 1, 0).day;
    final day = parts[2] < targetLen ? parts[2] : targetLen;
    select(dateKey(DateTime(parts[0], parts[1] + months, day)));
  }

  void resetToToday() => state = dateKey(DateTime.now());

  bool get isToday => state == dateKey(DateTime.now());
}

final homeDateProvider = NotifierProvider<ActiveWriteDateNotifier, String>(
  ActiveWriteDateNotifier.new,
);

/// Auto-save debounce; overridden to zero in widget tests.
final debounceDurationProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 400),
);

final topLevelMetricsProvider = StreamProvider<List<Metric>>(
  (ref) => ref.watch(entryRepositoryProvider).watchTopLevelMetrics(),
);

final childrenProvider = StreamProvider.family<List<Metric>, int>(
  (ref, parentId) => ref.watch(entryRepositoryProvider).watchChildren(parentId),
);

final metricOptionsProvider = StreamProvider.family<List<MetricOption>, int>(
  (ref, metricId) => ref.watch(entryRepositoryProvider).watchOptions(metricId),
);

final entriesForDateProvider = StreamProvider.family<Map<int, Entry>, String>(
  (ref, date) => ref.watch(entryRepositoryProvider).watchEntriesFor(date),
);

final selectedOptionsProvider =
    StreamProvider.family<Map<int, Set<int>>, String>(
      (ref, date) =>
          ref.watch(entryRepositoryProvider).watchSelectedOptionsFor(date),
    );
