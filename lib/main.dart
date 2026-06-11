import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/shell/root_pager.dart';

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
      home: const RootPager(),
    );
  }
}
