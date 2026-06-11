import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db/app_database.dart';
import 'data/db/database_provider.dart';

void main() {
  runApp(const ProviderScope(child: DailyTrackerApp()));
}

class DailyTrackerApp extends StatelessWidget {
  const DailyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Tracker',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF39D353),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

/// Placeholder home for phase 0 — proves the encrypted DB opens and the
/// seed is present. Replaced by the entry card list in phase 1.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Tracker')),
      body: StreamBuilder<List<Metric>>(
        stream: db.select(db.metrics).watch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final metrics = snapshot.data!;
          return ListView(
            children: [
              for (final metric in metrics)
                ListTile(
                  title: Text(metric.title),
                  subtitle: Text(metric.inputType),
                  trailing: metric.isStarred ? const Icon(Icons.star) : null,
                ),
            ],
          );
        },
      ),
    );
  }
}
