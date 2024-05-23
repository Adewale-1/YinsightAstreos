import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yinsight/Globals/services/userInfo.dart';
import 'package:yinsight/Screens/HomePage/models/task_model.dart';
import 'package:http/http.dart' as http;


/// A provider for managing task states.
final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  return TasksNotifier();
});

/// A class for managing tasks with state management.
class TasksNotifier extends StateNotifier<List<Task>> {
    /// Creates a [TasksNotifier] instance.
    TasksNotifier() : super([]) {
        fetchTasksFromBackend();
    }




  /// Fetches tasks from the backend.
  Future<void> fetchTasksFromBackend() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      if (token == null) throw Exception('Token not found');

      final response = await http.get(
        Uri.parse(UserInformation.getRoute('getCreatedTasks')),
        headers: {'Authorization': token}
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final tasks = (data['tasks'] as List).map((e) => Task.fromJson(e)).toList();
        state = tasks; // Update state here
      } else {
        state = []; // Handle non-successful responses
        throw Exception('Failed to fetch tasks');
      }
    } catch (e) {
      state = []; // Handle errors
      // You might want to log this exception
    }
  }

  void refreshTasks() {
    fetchTasksFromBackend();
  }
  
  /// Adds a task to the state.
  ///
  /// [task]: The task to add.
  void addTask(Task task) {
    state = [...state, task];
  }
  
  
  List<Task> _originalList = [];

  void removeTaskFromList(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
  }

  // Start dragging task
  void startDraggingTask(Task task) {
    _originalList = List.from(state); // Backup the original list
    state = state.where((t) => t.id != task.id).toList();
  }
  void refreshTasksFromBackend() async {
    // print("Refreshing tasks from backend...");
    // You can adjust fetch logic to ensure you're getting the latest data
    fetchTasksFromBackend();
  }
  // Cancel dragging task
  void cancelDraggingTask(Task task) {
    if (!_originalList.contains(task)) {
      _originalList.add(task); // Reinsert the task if it's not in the original list
    }
    state = List.from(_originalList);
    _originalList = []; // Clear the backup
  }


  // Call this method when a task is dropped onto a calendar timeslot
  void assignTaskToTimeSlot(WidgetRef ref, Task task, DateTime timeForSlot) {
    // print("Assigning priority: ${task.priority} to task: ${task.name}");
      // Remove the task from the unassigned tasks list
      state = state.map((t) {
      if (t.id == task.id) {
        // taskFound = true;
        return t.copyWith(assignedTime: timeForSlot);
      }
      return t;
    }).toList();
      
      ref.read(calendarTasksProvider.notifier).addTaskToCalendar(task, timeForSlot);

      // Notify the tasksProvider and calendarTasksProvider of the changes
      ref.invalidate(tasksProvider);
      ref.invalidate(calendarTasksProvider);
      // Notify listeners to rebuild widgets
      state = List.from(state);
    }



    void unassignTask(WidgetRef ref, Task task) {
      // Access the current state of calendarTasksProvider
      // Access the current state of calendarTasksProvider
      final calendarTasksNotifier = ref.read(calendarTasksProvider.notifier);
      calendarTasksNotifier.removeTaskFromCalendar(task, task.assignedTime!);

      // Depending on your logic, you might add the task back to the unassigned list
      state = [...state, task];
    }
  }



// Create a new provider for tasks assigned to the calendar.
final calendarTasksProvider = StateNotifierProvider<CalendarTasksNotifier, Map<DateTime, List<Task>>>((ref) {
  return CalendarTasksNotifier();
});

class CalendarTasksNotifier extends StateNotifier<Map<DateTime, List<Task>>> {
  CalendarTasksNotifier() : super({});

  void addTaskToCalendar(Task task, DateTime timeForSlot) {
    state = {
      ...state,
      timeForSlot: (state[timeForSlot] ?? []) + [task],
    };
  }

  void removeTaskFromCalendar(Task task, DateTime timeForSlot) {
    final updatedTasks = state[timeForSlot]?.where((t) => t.id != task.id).toList() ?? [];
    state = {
      ...state,
      timeForSlot: updatedTasks,
    };
  }



  // Add this method to update all tasks for a specific date
  void updateTasksForDate(DateTime date, List<Task> tasks) {
    // This will set the tasks for the entire day at each hour slot
    // Clear any existing tasks for this date
    Map<DateTime, List<Task>> updatedState = Map.from(state);
    for (int hour = 0; hour < 24; hour++) {
      DateTime timeForSlot = DateTime(date.year, date.month, date.day, hour);
      updatedState[timeForSlot] = tasks.where((t) => t.assignedTime?.hour == hour).toList();
    }
    state = updatedState;
  }
}