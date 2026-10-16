import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global tab indices. The Not app keeps only Analysis + Main from the
/// monolith's 5-tab shell (CR-3 §2) and always opens on Main.
class AppTab {
  AppTab._();

  static const analysis = 0;
  static const main = 1;

  static const count = 2;
  static const initial = main;
}

/// Selected bottom-nav / PageView tab. Notification taps drive it via
/// [goTo]; the shell keeps the PageView in sync. Not persisted — every
/// launch starts on Main.
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
