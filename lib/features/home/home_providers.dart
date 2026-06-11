import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_key.dart';
import '../../data/db/app_database.dart';
import '../../data/db/database_provider.dart';
import '../../data/repositories/entry_repository.dart';
import '../../data/repositories/tree_repository.dart';

final entryRepositoryProvider = Provider<EntryRepository>(
    (ref) => EntryRepository(ref.watch(databaseProvider)));

final treeRepositoryProvider = Provider<TreeRepository>(
    (ref) => TreeRepository(ref.watch(databaseProvider)));

/// True while a card is being long-press dragged — gap targets light up.
class DraggingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final draggingProvider =
    NotifierProvider<DraggingNotifier, bool>(DraggingNotifier.new);

/// v1: the home page always edits TODAY (spec open point #6).
final homeDateProvider = Provider<String>((ref) => dateKey(DateTime.now()));

/// Auto-save debounce; overridden to zero in widget tests.
final debounceDurationProvider =
    Provider<Duration>((ref) => const Duration(milliseconds: 400));

final topLevelMetricsProvider = StreamProvider<List<Metric>>(
    (ref) => ref.watch(entryRepositoryProvider).watchTopLevelMetrics());

final childrenProvider = StreamProvider.family<List<Metric>, int>(
    (ref, parentId) =>
        ref.watch(entryRepositoryProvider).watchChildren(parentId));

final metricOptionsProvider = StreamProvider.family<List<MetricOption>, int>(
    (ref, metricId) =>
        ref.watch(entryRepositoryProvider).watchOptions(metricId));

final entriesForDateProvider = StreamProvider.family<Map<int, Entry>, String>(
    (ref, date) => ref.watch(entryRepositoryProvider).watchEntriesFor(date));

final selectedOptionsProvider =
    StreamProvider.family<Map<int, Set<int>>, String>((ref, date) =>
        ref.watch(entryRepositoryProvider).watchSelectedOptionsFor(date));

final hasTransactionsProvider = StreamProvider.family<bool, String>(
    (ref, date) =>
        ref.watch(entryRepositoryProvider).watchHasTransactions(date));
