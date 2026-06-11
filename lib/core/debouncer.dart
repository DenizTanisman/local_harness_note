import 'dart:async';

/// Trailing-edge debouncer for auto-save (spec 6.2).
class Debouncer {
  Debouncer(this.duration);

  final Duration duration;
  Timer? _timer;

  void call(void Function() action) {
    _timer?.cancel();
    if (duration == Duration.zero) {
      action();
    } else {
      _timer = Timer(duration, action);
    }
  }

  void dispose() => _timer?.cancel();
}
