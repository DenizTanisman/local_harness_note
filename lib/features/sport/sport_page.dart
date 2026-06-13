import 'package:flutter/material.dart';

import '../../theme/glow_background.dart';

/// Sport tab (CR-3 §6). Programs + calorie tracking land in CR3-P5/P6;
/// this is the P0 stub.
class SportPage extends StatelessWidget {
  const SportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sport')),
      body: const GlowBackground(
        child: Center(child: Text('Sport — coming soon')),
      ),
    );
  }
}
