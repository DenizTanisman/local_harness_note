import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/secure_window.dart';
import '../analysis/analysis_page.dart';
import '../detail/metric_detail_page.dart';
import '../health/health_page.dart';
import '../home/home_page.dart';
import '../money/money_page.dart';
import '../settings/settings_providers.dart';
import '../sport/sport_page.dart';
import 'tab_index.dart';

/// 5-tab shell (CR-3 §2): global horizontal swipe + bottom navigation,
/// kept in sync. Opens on Main (index 2).
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late final PageController _controller = PageController(
    initialPage: AppTab.initial,
  );
  bool _secured = false;

  @override
  void initState() {
    super.initState();
    // FLAG_SECURE (spec §11.6 / CR-3 §14) — app-wide when enabled, since
    // both Money and Health live in the always-built PageView. Default off.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = await ref.read(settingsRepositoryProvider).loadAll();
      if (mounted && settings['flag_secure'] == 'true') {
        _secured = true;
        await SecureWindow.enable();
      }
    });
  }

  @override
  void dispose() {
    if (_secured) SecureWindow.disable();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Deep links / notification taps move the tab via the provider; mirror
    // that onto the PageView.
    ref.listen<int>(tabIndexProvider, (prev, next) {
      if (!_controller.hasClients) return;
      if (_controller.page?.round() != next) {
        _controller.jumpToPage(next);
      }
    });
    final index = ref.watch(tabIndexProvider);

    return Scaffold(
      body: PageView(
        controller: _controller,
        // Global swipe always changes tabs (CR-3 §2). Inner tab bars use
        // tap-only controls so they never steal this gesture.
        onPageChanged: (i) => ref.read(tabIndexProvider.notifier).goTo(i),
        children: [
          const MoneyPage(),
          AnalysisPage(
            onMetricTap: (metric) {
              // Money breakdown rows are read-only in Analysis (CR-3 §4).
              if (metric.inputType == 'money') return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MetricDetailPage(metric: metric),
                ),
              );
            },
          ),
          const HomePage(),
          const HealthPage(),
          const SportPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(tabIndexProvider.notifier).goTo(i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Money',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Analysis',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Main',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Health',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Sport',
          ),
        ],
      ),
    );
  }
}
