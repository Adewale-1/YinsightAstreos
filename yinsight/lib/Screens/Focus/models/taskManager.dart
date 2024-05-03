import 'package:flutter/material.dart';
import 'dart:async';

class Task {
  String name;
  String id;
  Duration elapsed;
  Timer? timer;

  Task({required this.name, required this.id, this.elapsed = Duration.zero, this.timer});
}

class TaskManager with ChangeNotifier {
  List<Task> tasks = [];
  bool isLoading = false;

  // Fetch tasks from the backend
  Future<void> fetchTasks() async {
    isLoading = true;
    notifyListeners();
    // Add your http call here
    isLoading = false;
    notifyListeners();
  }

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

  Future<void> updateTaskTime(Task task) async {
    // Your http POST call to update the backend
  }

  @override
  void dispose() {
    for (var task in tasks) {
      task.timer?.cancel();
    }
    super.dispose();
  }
}
