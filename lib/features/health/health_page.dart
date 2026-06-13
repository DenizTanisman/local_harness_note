import 'package:flutter/material.dart';

import '../../theme/glow_background.dart';

/// Health tab (CR-3 §5). Profile + body + calculations + sensor block
/// land in CR3-P3; this is the P0 stub.
class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health')),
      body: const GlowBackground(
        child: Center(child: Text('Health — coming soon')),
      ),
    );
  }
}
