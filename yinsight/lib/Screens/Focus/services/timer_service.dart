
// import 'dart:async';

// /// A service to manage timers.
// class TimerService {
//   Timer? _timer;
//   Function? onUpdate;
//   /// Starts the timer and calls the update function periodically.
//   ///
//   /// [onUpdate]: The function to call on each timer tick.
//   void startTimer({required Function onUpdate}) {
//     this.onUpdate = onUpdate;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       onUpdate(); // Call the update function every second
//         });
//   }
//   /// Stops the timer.
//   void stopTimer() {
//     _timer?.cancel();
//   }
// }

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// A service to manage timers.
class TimerService {
  final Map<String, Timer> _timers = {};
  final Map<String, Duration> _elapsedTimes = {};
  final Map<String, Function(Duration)> _onUpdateCallbacks = {};

  /// Starts the timer for a specific task and calls the update function periodically.
  ///
  /// [taskId]: The identifier of the task.
  /// [onUpdate]: The function to call on each timer tick, with the elapsed time as a parameter.
  void startTimer(String taskId, Function(Duration) onUpdate, Duration elapsedTime) {
    stopTimer(taskId); // Ensure no duplicate timer exists for the task
    updateElapsedTime(taskId, elapsedTime);

    _onUpdateCallbacks[taskId] = onUpdate;
    _elapsedTimes[taskId] ??= Duration.zero;

    _timers[taskId] = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTimes[taskId] = _elapsedTimes[taskId]! + const Duration(seconds: 1);
      onUpdate(_elapsedTimes[taskId]!); // Call the update function with elapsed time
    });
  }

  /// Pauses the timer for a specific task.
  ///
  /// [taskId]: The identifier of the task.
  void pauseTimer(String taskId) {
    _timers[taskId]?.cancel();
    _timers.remove(taskId);
  }

  /// Stops the timer for a specific task.
  ///
  /// [taskId]: The identifier of the task.
  void stopTimer(String taskId) {
    _timers[taskId]?.cancel();
    _timers.remove(taskId);
  }

  /// Stops all timers.
  void stopAllTimers() {
    _timers.values.forEach((timer) => timer.cancel());
    _timers.clear();
  }

  // /// Saves the state of all timers.
  // void saveTimersState() {
  //   // This can be extended to save timers' state to persistent storage if needed
  // }

  // /// Restores the state of all timers.
  // /// [onUpdate]: The function to call on each timer tick, with the elapsed time as a parameter.
  // void restoreTimersState(Function(String, Duration) onUpdate) {
  //   _timers.forEach((taskId, _) {
  //     startTimer(taskId, (elapsedTime) => onUpdate(taskId, elapsedTime));
  //   });
  // }

  // Save the timers' state to persistent storage (SharedPreferences)
  Future<void> saveTimersState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _elapsedTimes.forEach((taskId, elapsedTime) {
      prefs.setInt(taskId, elapsedTime.inSeconds);
    });
  }

  // Restore timers' state from persistent storage and restart timers
  Future<void> restoreTimersState(Function(String, Duration) onUpdate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (String taskId in _elapsedTimes.keys) {
      int? elapsedSeconds = prefs.getInt(taskId);
      if (elapsedSeconds != null) {
        Duration elapsedTime = Duration(seconds: elapsedSeconds);
        _elapsedTimes[taskId] = elapsedTime;
        onUpdate(taskId, elapsedTime);
        startTimer(taskId, (newElapsedTime) => onUpdate(taskId, newElapsedTime), elapsedTime);
      }
    }
  }

  /// Gets the elapsed time for a specific task.
  ///
  /// [taskId]: The identifier of the task.
  Duration getElapsedTime(String taskId) {
    return _elapsedTimes[taskId] ?? Duration.zero;
  }

  /// Updates the elapsed time for a specific task.
  ///
  /// [taskId]: The identifier of the task.
  /// [elapsedTime]: The new elapsed time.
  void updateElapsedTime(String taskId, Duration elapsedTime) {
    _elapsedTimes[taskId] = elapsedTime;
  }
}
