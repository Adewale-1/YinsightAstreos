import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yinsight/Globals/services/userInfo.dart';
import 'package:yinsight/Screens/Focus/services/timer_service.dart';
import 'package:http/http.dart' as http;

class focusSection extends StatefulWidget {
  const focusSection({super.key});

  @override
  State<focusSection> createState() => focusSectionState();
}



class focusSectionState extends State<focusSection>with WidgetsBindingObserver {

  final TextEditingController _searchController = TextEditingController();

  Map<String, bool> taskCompletionStatus = {};
  
  List<String> allTasks = [];
  List<String> displayedTasks = [];
  Map<String, bool> taskStatus = {};
  // New fields to track timer and elapsed time for each task
  Map<String, Timer?> taskTimers = {};
  Map<String, Duration> taskElapsedTimes = {};
  Map<String, String> taskDetails = {};
   Map<String, String> taskIds = {}; // Map to hold task names and their corresponding IDs


  final TimerService _timerService = TimerService();

  @override
  void initState() {
     super.initState();
     _fetchTasks();
    _searchController.addListener(_updateDisplayedTasks);
    _checkFirstTime();

    // Add a listener for the app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Fetch the total time spent for each task
    for (final task in allTasks) {
      fetchTotalTimeSpent(task);
    }
  }


void _showDeleteConfirmationDialog(String task) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Complete Task'),
        content: Text('Have you completed "$task"?'),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              _deleteTask(task); // Call your delete task method
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}


Future<void> _deleteTask(String taskName) async {
  String? taskId = taskIds[taskName]; // Retrieve the task ID as a string
  if (taskId == null) {
    // print('Error: Task ID not found for task $taskName');
    return;
  }

  // print('Task ID: $taskId');

  try {
    final user = FirebaseAuth.instance.currentUser;
    String? token = await user?.getIdToken();
    final String url = '${UserInformation.getRoute('deleteTaskOnFocus')}?task_id=$taskId';
    if (token == null) throw Exception('No token found');
    var response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      // print('Task deleted successfully');
      setState(() {
        allTasks.remove(taskName);
        displayedTasks.remove(taskName);
        taskStatus.remove(taskName);
        taskElapsedTimes.remove(taskName);
        taskDetails.remove(taskName);
        taskIds.remove(taskName);
        taskCompletionStatus.remove(taskName);
      });
    } else {
      throw Exception('Failed to delete task');
    }
  } catch (e) {
    // print('Error deleting task: $e');
  }
}

void _fetchTasks() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    String? token = await user?.getIdToken();
    // print("Fetching tasks");

    if (token == null) throw Exception('No token found');
    var response = await http.get(
      Uri.parse(UserInformation.getRoute('getFocusTasks')),
      headers: {
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // print("Data: $data");
        setState(() {
          allTasks = List<String>.from(data['tasks_with_expected_time_to_complete'].map((task) => task['name']));
          displayedTasks = allTasks;

          for (var task in data['tasks_with_expected_time_to_complete']) {
            final taskName = task['name'];
            final taskId = extractTaskId(task['id']); // Assuming 'id' field is a list containing the ID string
            final expectedTimeToComplete = task['expectedTimeToComplete'];
            final formattedExpectedTime = formatTimeToHoursAndMinutes(expectedTimeToComplete);
            taskIds[taskName] = taskId; // Store the task ID in the map
            taskStatus[taskName] = false;
            taskElapsedTimes[taskName] = Duration.zero;
            taskTimers[taskName] = null;
            taskDetails[taskName] = formattedExpectedTime;
          }
        });
    } else {
      throw Exception('Failed to load tasks');
    }
  } catch (e) {
    // print('Error fetching tasks: $e');
  }
}
String extractTaskId(String taskIdString) {
  if (taskIdString.startsWith('[#') && taskIdString.endsWith(']')) {
    return taskIdString.substring(2, taskIdString.length - 1);
  } else {
    throw Exception('Malformed task ID string: $taskIdString');
  }
}

String formatTimeToHoursAndMinutes(String time) {
  final parts = time.split(':');
  if (parts.length != 2) return "";
  final hours = int.parse(parts[0]);
  final minutes = int.parse(parts[1]);
  return "${hours}h ${minutes}m";
}

@override
void dispose() {
  _searchController.dispose();
  _timerService.stopTimer();
  taskTimers.forEach((key, timer) => timer?.cancel()); // Cancel all timers
  taskDetails.clear();

  // Remove the app lifecycle observer
  WidgetsBinding.instance.removeObserver(this);

  super.dispose();
}

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  super.didChangeAppLifecycleState(state);

  // Check if the app is brought to the foreground
  if (state == AppLifecycleState.resumed) {
    _fetchTasks();
    // Fetch the total time spent for each task
    for (final task in allTasks) {
      fetchTotalTimeSpent(task);
    }
  }
}


Duration parseDuration(String input) {
  final parts = input.split(':');
  if (parts.length != 2) {
    return Duration.zero;
  }
  final hours = int.parse(parts[0]);
  final minutes = int.parse(parts[1]);
  return Duration(hours: hours, minutes: minutes);
}

  void _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isSecondTime = (prefs.getBool('isSecondTime') ?? true);
    
    if (isSecondTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog();
      });
      await prefs.setBool('isSecondTime', false);
    }
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Lets go! 🚀"),
          content: const Text(
          "🎯 Welcome to the Focus Section! 🎯\n\n"
          "Here, you can check out all your tasks along with their estimated completion times 🕘. This handy section helps you track the actual duration each task takes. Need to find something quickly? Just use the search bar 🔎 to zero in on any task.\n\n"
          "And hey, if you need to take a breather 🥱, no worries! The time you’ve already put in will be safely saved. So, take your time and focus on what matters!"
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Got It!"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
Future<void> fetchTotalTimeSpent(String taskName) async {
  final user = FirebaseAuth.instance.currentUser;
  String? token = await user?.getIdToken();

  if (token == null) {
    throw Exception('No token found');
  }

  final taskId = taskIds[taskName];
  if (taskId == null) {
    // print('Error: Task ID not found for task $taskName');
    return;
  }

  final response = await http.get(
    Uri.parse('${UserInformation.getRoute('getTotalTimeSpentForTask')}?task_id=$taskId'),
    headers: {
      'Authorization': token,
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final totalTimeSpent = data['total_time_spent'];
    if (totalTimeSpent != null) {
      setState(() {
        taskElapsedTimes[taskName] = parseDuration(totalTimeSpent);
      });
    }
  } else {
    throw Exception('Failed to fetch total time spent');
  }
}

void startTimer(String task) {
  // Cancel any existing timer for this task
  taskTimers[task]?.cancel();
  taskTimers[task] = null;

  // Start a new timer for this task
  taskTimers[task] = Timer.periodic(
    const Duration(seconds: 1),
    (timer) {
      setState(() {
        taskElapsedTimes[task] = taskElapsedTimes[task]! + const Duration(seconds: 1);
      });
    },
  );
}


Future<void> pauseTimer(String task) async {
  setState(() {
    taskStatus[task] = false;
  });
  taskTimers[task]?.cancel(); // Cancel the timer for this specific task
  taskTimers[task] = null; // Set the timer to null

  // Get the elapsed time for the task
  Duration elapsedTime = taskElapsedTimes[task] ?? Duration.zero;

  // Format the elapsed time to the required format (HH:MM)
  String formattedTime = formatDuration(elapsedTime);

  try {
    // Make a request to the server to update the total time spent
    await updateTotalTimeSpent(task, formattedTime);
  } catch (e) {
    // print('Error updating total time spent: $e');
  }
}
Future<void> updateTotalTimeSpent(String taskName, String totalTimeSpent) async {
  final user = FirebaseAuth.instance.currentUser;
  String? token = await user?.getIdToken();

  if (token == null) {
    throw Exception('No token found');
  }

  final String taskId = taskIds[taskName] ?? '';


  final response = await http.post(
    Uri.parse(UserInformation.getRoute('updateTotalTimeSpentForTask')),
    headers: {
      'Authorization': token,
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'task_id': taskId,
      'total_time_spent': totalTimeSpent,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update total time spent');
  }
}
String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$hours:$minutes:$seconds";
}


  void _updateDisplayedTasks() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      setState(() {
        displayedTasks = allTasks.where((task) => task.toLowerCase().contains(query.toLowerCase())).toList();
      });
    } else {
      setState(() {
        displayedTasks = allTasks;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final formattedDate = DateFormat('E MMM dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5.0),
          Padding(
            padding: const EdgeInsets.all(11),
            child: Row(
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  ' Today',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5.0),
          Expanded(
            child: displayedTasks.isNotEmpty
                ? ListView.builder(
                    itemCount: displayedTasks.length,
                    itemBuilder: (context, index) {
                      final taskName = displayedTasks[index];
                      // Use the formatDuration method to get the time string
                      final timeString = formatDuration(taskElapsedTimes[taskName] ?? Duration.zero);
                      return taskContainer(
                        context,
                        task: taskName,
                        time: timeString,
                      );
                    },
                  )
                : const Center(
                    child: Text("No tasks found matching your search.", style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }



  Widget taskContainer(BuildContext context, {required String task, required String time}) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _taskAndTimeRow(task, time),
          _statusIndicator(),
          _actionAndTimeDetailsRow(task),
        ],
      ),
    );
  }

  Widget _taskAndTimeRow(String task, String time) {
    return Row(
      key: ValueKey('${task}_$time'),
      children: [
        Expanded(
          child: Row(
            children: [
              Checkbox(
                value: taskCompletionStatus[task] ?? false, // Use the completion status
                onChanged: (bool? value) {
                  if (value != null) {
                    setState(() {
                      taskCompletionStatus[task] = value; // Update the completion status
                      if (value) {
                        _showDeleteConfirmationDialog(task); // Show the confirmation dialog
                      }
                    });
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              Expanded(
                child: Text(
                  task,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  // Function for the Status Indicator
  Widget _statusIndicator() {
    return Row(
      children: [
        const SizedBox(width: 50),
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(right: 8.0),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green, // Example color
          ),
        ),
      ],
    );
  }



Widget _actionAndTimeDetailsRow(String task) {
  bool? taskStatusValue = taskStatus[task];
  Duration? taskElapsedTimeValue = taskElapsedTimes[task];
  String? taskDetailsValue = taskDetails[task];

  if (taskStatusValue == null || taskElapsedTimeValue == null || taskDetailsValue == null) {
    // Handle the case where any of the required values are null
    return const SizedBox.shrink();
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton(
        icon: Icon(
          taskStatusValue ? Icons.pause : Icons.play_arrow,
          size: 40,
          color: Colors.grey[400],
        ),
        onPressed: () {
          if (!taskStatusValue) {
            // Start or resume the timer
            setState(() {
              taskStatus[task] = true;
            });
            startTimer(task);
          } else {
            // Pause the timer
            pauseTimer(task);
          }
        },
      ),
      Row(
        children: [
          _timeDetailsColumn('Actual', formatDuration(taskElapsedTimeValue)),
          const SizedBox(width: 10),
          _timeDetailsColumn('Expected', taskDetailsValue),
        ],
      ),
    ],
  );
}
  // Helper function for creating time details columns
  Widget _timeDetailsColumn(String title, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),

        Text(
          time,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
