import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/secure_window.dart';
import '../analysis/analysis_page.dart';
import '../detail/metric_detail_page.dart';
import '../home/home_page.dart';
import '../home/instagram_autofill.dart';
import '../settings/settings_providers.dart';
import 'tab_index.dart';

/// 2-tab shell (Analysis, Main — CR-3 §2 minus the tabs that moved to the
/// Para / Program apps): global horizontal swipe + bottom navigation, kept
/// in sync. Opens on Main (index 1).
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  late final PageController _controller = PageController(
    initialPage: AppTab.initial,
  );
  bool _secured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // FLAG_SECURE (spec §11.6 / CR-3 §14) — app-wide when enabled, since
    // both tabs live in the always-built PageView. Default off.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = await ref.read(settingsRepositoryProvider).loadAll();
      if (mounted && settings['flag_secure'] == 'true') {
        _secured = true;
        await SecureWindow.enable();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // CR-4 §3.3: pick up screen time the Program app measured while we were
    // in the background (silent no-op when Program is absent).
    if (state == AppLifecycleState.resumed) {
      ref.read(instagramAutofillProvider).run();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_secured) SecureWindow.disable();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Notification taps move the tab via the provider; mirror
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
          AnalysisPage(
            onMetricTap: (metric) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MetricDetailPage(metric: metric),
                ),
              );
            },
          ),
          const HomePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(tabIndexProvider.notifier).goTo(i),
        destinations: const [
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
        ],
      ),
    );
  }
}
