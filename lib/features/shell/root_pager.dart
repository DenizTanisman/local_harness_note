import 'package:flutter/material.dart';

import '../analysis/analysis_page.dart';
import '../detail/metric_detail_page.dart';
import '../home/home_page.dart';

/// Horizontal PageView: [0] entry ↔ [1] analysis (spec 6.1).
/// The app always opens on the entry page.
class RootPager extends StatefulWidget {
  const RootPager({super.key});

  @override
  State<RootPager> createState() => _RootPagerState();
}

class _RootPagerState extends State<RootPager> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: [
        const HomePage(),
        AnalysisPage(
          onMetricTap: (metric) {
            // Money routes to its own page in phase 5.
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MetricDetailPage(metric: metric),
            ));
          },
        ),
      ],
    );
  }
}
