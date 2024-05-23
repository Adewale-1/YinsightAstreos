import 'dart:async';

/// A service to manage timers.
class TimerService {
  Timer? _timer;
  Function? onUpdate;
  /// Starts the timer and calls the update function periodically.
  ///
  /// [onUpdate]: The function to call on each timer tick.
  void startTimer({required Function onUpdate}) {
    this.onUpdate = onUpdate;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      onUpdate(); // Call the update function every second
        });
  }
  /// Stops the timer.
  void stopTimer() {
    _timer?.cancel();
  }
}