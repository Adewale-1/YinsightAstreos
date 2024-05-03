import 'dart:async';

class TimerService {
  Timer? _timer;
  Function? onUpdate;

  void startTimer({required Function onUpdate}) {
    this.onUpdate = onUpdate;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      onUpdate(); // Call the update function every second
        });
  }

  void stopTimer() {
    _timer?.cancel();
  }
}