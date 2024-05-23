import 'package:flutter/material.dart';
import 'dart:async';

/// A class representing a task.
class Task {
  String name;
  String id;
  Duration elapsed;
  Timer? timer;

  /// Creates a [Task] instance.
  ///
  /// [name]: The name of the task.
  /// [id]: The unique identifier of the task.
  /// [elapsed]: The elapsed time for the task.
  /// [timer]: An optional timer for the task.
  Task({required this.name, required this.id, this.elapsed = Duration.zero, this.timer});
}

/// A class to manage tasks with state management.
class TaskManager with ChangeNotifier {
  List<Task> tasks = [];
  bool isLoading = false;

  /// Fetches tasks from the backend.
  Future<void> fetchTasks() async {
    isLoading = true;
    notifyListeners();

    isLoading = false;
    notifyListeners();
  }

  /// Stops the timer for a given task.
  ///
  /// [task]: The task to stop the timer for.
  void startTimer(Task task) {
    task.timer?.cancel();
    task.timer = Timer.periodic(const Duration(seconds: 1), (_) {
      task.elapsed += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void stopTimer(Task task) {
    updateTaskTime(task);
    task.timer?.cancel();
    task.timer = null;
    notifyListeners();
  }

  /// Updates the elapsed time for a given task in the backend.
  ///
  /// [task]: The task to update the time for.
  Future<void> updateTaskTime(Task task) async {
    // http POST call to update the backend
  }

  @override
  void dispose() {
    for (var task in tasks) {
      task.timer?.cancel();
    }
    super.dispose();
  }
}
