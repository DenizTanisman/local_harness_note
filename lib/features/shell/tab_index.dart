import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global tab indices (CR-3 §2). The app always opens on Main.
class AppTab {
  AppTab._();

  static const money = 0;
  static const analysis = 1;
  static const main = 2;
  static const health = 3;
  static const sport = 4;

  static const count = 5;
  static const initial = main;
}

/// Selected bottom-nav / PageView tab. Deep links (Main summary cards,
/// notification taps) drive it via [goTo]; the shell keeps the PageView in
/// sync. Not persisted — every launch starts on Main.
class TabIndexNotifier extends Notifier<int> {
  @override
  int build() => AppTab.initial;

  void goTo(int index) {
    if (index < 0 || index >= AppTab.count) return;
    state = index;
  }
}

final tabIndexProvider = NotifierProvider<TabIndexNotifier, int>(
  TabIndexNotifier.new,
);
