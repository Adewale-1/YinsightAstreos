import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yinsight/Globals/services/userInfo.dart';
import 'package:yinsight/Screens/HomePage/models/task_model.dart';
import 'package:yinsight/Screens/HomePage/services/tasks_notifier.dart';
import 'package:http/http.dart' as http;

/// A section of the calendar displaying tasks.
class CalendarSection extends ConsumerStatefulWidget {
  final void Function(DateTime)? onTaskDropped;

  /// Creates a [CalendarSection] instance.
  ///
  /// [onTaskDropped]: Callback function to handle task drop events.
  const CalendarSection({
    super.key,
    this.onTaskDropped,
  });

  @override
  _CalendarSectionState createState() => _CalendarSectionState();
}

class _CalendarSectionState extends ConsumerState<CalendarSection> {
  @override
  void initState() {
    super.initState();
    // Fetch tasks for the selected day when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchTasksForSelectedDay(ref, ref.read(selectedDateProvider));
    });
  }

  final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

  /// Checks if two [DateTime] objects are on the same day.
  ///
  /// [date1]: The first date.
  /// [date2]: The second date.
  ///
  /// Returns true if both dates are on the same day, false otherwise.
  bool isSameDay(DateTime? date1, DateTime? date2) {
    return date1 != null &&
        date2 != null &&
        date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Builds a widget to display tasks for a specific hour in the calendar.
  ///
  /// [isHighlighted]: Whether the time slot is highlighted.
  /// [timeForSlot]: The time slot to display tasks for.
  /// [tasksForThisHour]: The tasks to display for the time slot.
  ///
  /// Returns the widget to display tasks.
  Widget _addTaskDisplayOnCalendar(
      bool isHighlighted, DateTime timeForSlot, List<Task> tasksForThisHour) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.grey[300] : Colors.transparent,
        borderRadius: BorderRadius.circular(9.0),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Text(
              DateFormat('ha').format(timeForSlot),
              style: GoogleFonts.lexend(
                textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tasksForThisHour
                  .where((task) =>
                      task.assignedTime != null &&
                      isSameHour(task.assignedTime!, timeForSlot))
                  .map((task) {
                final color = getColorForPriority(task.priority);
                return Container(
                  height: 50,
                  width: 150,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(9.0),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            task.name,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(color: Colors.grey),
        ],
      ),
    );
  }

  /// Checks if two [DateTime] objects are on the same hour.
  ///
  /// [dt1]: The first date-time.
  /// [dt2]: The second date-time.
  ///
  /// Returns true if both date-times are in the same hour, false otherwise.
  bool isSameHour(DateTime dt1, DateTime dt2) {
    return dt1.hour == dt2.hour;
  }

  /// Gets the color associated with a task's priority.
  ///
  /// [priority]: The priority of the task.
  ///
  /// Returns the color corresponding to the priority.
  Color getColorForPriority(TaskPriority priority) {
    // print("Getting color for priority: $priority");
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.low:
        return Colors.green;
      default:
        return Colors.grey; // Handle the default case
    }
  }

  /// Fetches tasks for the selected day from the backend.
  ///
  /// [ref]: The widget reference.
  /// [date]: The date to fetch tasks for.
  Future<void> fetchTasksForSelectedDay(WidgetRef ref, DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    String? token = await user?.getIdToken();
    if (token == null) {
      // print("No token found");
      return;
    }

    final formattedDate =
        DateFormat('yyyy-MM-dd').format(date); // Ensure format is correct
    final uri = Uri.parse(
        '${UserInformation.getRoute('getDateFilteredTasksInHomeCalendar')}?date=$formattedDate');
    // print("Fetching tasks with URI: $uri"); // Log the full URI being hit

    final response = await http.get(
      uri,
      headers: {'Authorization': token},
    );

    // print("Response Status: ${response.statusCode}"); // Log the status code
    // print("Response Body: ${response.body}"); // Log the response body

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      // print("JSON Response: $jsonResponse");
      List<Task> tasks = (jsonResponse['tasks'] as List)
          .map((task) => Task.fromJson(task))
          .toList();
      ref.read(calendarTasksProvider.notifier).updateTasksForDate(date, tasks);
    } else {
      // print("Failed to load tasks for the selected date: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final Map<DateTime, List<Task>> calendarTasks =
        ref.watch(calendarTasksProvider);
    final isToday = DateFormat('yyyyMMdd').format(selectedDate) ==
        DateFormat('yyyyMMdd').format(DateTime.now());
    final formattedDate = DateFormat('EEE MMM d').format(selectedDate);
    final tasksForSelectedDay = ref
        .watch(tasksProvider)
        .where((task) => isSameDay(task.assignedTime, selectedDate))
        .toList();

    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: Colors.grey))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "$formattedDate ",
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: isToday ? 'Today' : '',
                            style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: isToday
                        ? null
                        : () {
                            DateTime newDate =
                                selectedDate.subtract(const Duration(days: 1));
                            ref.read(selectedDateProvider.notifier).state =
                                newDate;
                            fetchTasksForSelectedDay(ref, newDate);
                          },
                    tooltip: 'Previous Day',
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      DateTime newDate =
                          selectedDate.add(const Duration(days: 1));
                      ref.read(selectedDateProvider.notifier).state = newDate;
                      fetchTasksForSelectedDay(ref, newDate);
                    },
                    tooltip: 'Next Day',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 24,
                itemBuilder: (BuildContext context, int index) {
                  final hour = index;
                  final timeForSlot = DateTime(selectedDate.year,
                      selectedDate.month, selectedDate.day, hour);

                  final tasksForThisHour = calendarTasks[timeForSlot] ?? [];
                  return DragTarget<Task>(
                    onWillAccept: (Task? task) => true,
                    onAccept: (Task task) async {
                      // Create an updatedTask with the new assignedDate
                      final updatedTask = task.copyWith(
                        assignedDate: DateTime(selectedDate.year,
                            selectedDate.month, selectedDate.day),
                        assignedTime: timeForSlot,
                      );

                      // Use updatedTask to generate JSON for sending to the backend
                      final taskJson = updatedTask
                          .toJson(); // Use updatedTask here instead of task

                      final user = FirebaseAuth.instance.currentUser;
                      String? token = await user?.getIdToken();

                      if (token == null) throw Exception('No token found');

                      // Send the task to the backend

                      final response = await http.post(
                        Uri.parse(
                            UserInformation.getRoute('addTaskToHomeCalendar')),
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': token,
                        },
                        body: jsonEncode({"task": taskJson}),
                      );
                      // print("Task JSON: $taskJson\n");
                      // print("Response StatusFor Task: ${response.statusCode}"); // Log the status code
                      if (response.statusCode == 200) {
                        // Successfully added the task to the calendar, now update local state
                        ref
                            .read(calendarTasksProvider.notifier)
                            .addTaskToCalendar(updatedTask, timeForSlot);

                        // Optionally, fetch the updated tasks for the selected day
                        await fetchTasksForSelectedDay(ref, selectedDate);
                      } else {
                        // Handle error scenarios
                        // print("Failed to add the task to the calendar: ${response.body}");
                      }
                    },
                    builder: (BuildContext context, List<Task?> incoming,
                        List rejected) {
                      // Highlight the potential drop target timeslot
                      final isHighlighted = incoming.isNotEmpty;
                      // print("Timeeee >> : ${DateFormat('ha').format(timeForSlot)}");
                      // Tile layout for timeslot with tasks
                      return _addTaskDisplayOnCalendar(
                          isHighlighted, timeForSlot, tasksForThisHour);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
