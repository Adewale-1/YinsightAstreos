import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yinsight/Globals/services/userInfo.dart';

import 'package:yinsight/Screens/HomePage/models/task_model.dart';
import 'package:yinsight/Screens/HomePage/services/tasks_notifier.dart';
import 'package:yinsight/Screens/HomePage/widgets/TaskNotes/addTaskPage.dart';
import 'package:http/http.dart' as http;



class TaskSection extends ConsumerStatefulWidget {
  const TaskSection({super.key});

  @override
  _TaskSectionState createState() => _TaskSectionState();
}

class _TaskSectionState extends ConsumerState<TaskSection> {
  late Future<List<Task>> _tasksFuture;

  void _onTaskDropped(DateTime date) {
    refreshTasks();
  }

  @override
  void initState() {
    super.initState();
    _tasksFuture = fetchTasks();
    //  AwesomeNotifications().setListeners(onActionReceivedMethod: NotificationService.onActionReceivedMethod, onDismissActionReceivedMethod: NotificationService.onDismissActionReceivedMethod, onNotificationCreatedMethod: NotificationService.onNotificationCreatedMethod, onNotificationDisplayedMethod: NotificationService.onNotificationDisplayedMethod);
    // ref.read(tasksProvider.notifier).refreshTasksFromBackend();
  }

  void refreshTasks() {
    setState(() {
      _tasksFuture = fetchTasks();
    });
  }
  String priorityToString(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
      default:
        return 'Unknown';
    }
  }

  Future<List<Task>> fetchTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    String? token = await user?.getIdToken();

    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse(UserInformation.getRoute('getCreatedTasks')),
      headers: {
        'Authorization': token, 
      },
    ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error', 408); // Request Timeout response status code
        },
      );
    if (response.statusCode == 200) {
        // print("Tasks fetched successfully before: ${response.body}"); // Debug statement
        // Decode the response body into JSON
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        // Access the "tasks" key to get the list of tasks
        List<dynamic> tasksJson = jsonResponse['tasks'];
        // Map each task JSON to a Task object
        List<Task> tasks = tasksJson.map((taskJson) => Task.fromJson(taskJson)).toList();
        // print("Tasks fetched successfully: $tasks"); // Debug statement
        return tasks;
      } else {
        // print("Failed to load tasks, Status code: ${response.statusCode}"); // Debug statement
        throw Exception('Failed to load tasks from API');
    }
  }




  void _showAddTaskDialog(BuildContext context) async {
    // Open AddTaskPage and do not add the task again since it's already added in Save button onPressed
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddTaskPage(),
      ),
    );
    refreshTasks();
  }
  // Function to give numerical value to the priority for sorting (higher value means higher priority)
  int _priorityValue(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 3;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.low:
        return 1;
      default:
        return 0; // Unknown priority
    }
  }


  // Function to select a color based on priority
  Color _colorForPriority(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.low:
        return Colors.green;
      default:
        return Colors.grey; // Default color for unknown priority
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);

    return Expanded(


      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Tasks',
                    style: GoogleFonts.lexend(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 50.0,
                ),
                FloatingActionButton(
                  onPressed: () => _showAddTaskDialog(context),
                  backgroundColor: Colors.black,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: _tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (snapshot.hasData) {
                    List<Task> tasks = snapshot.data!;
                    //tasks.sort((a, b) => _priorityValue(b.priority).compareTo(_priorityValue(a.priority)));
                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        final priorityString = priorityToString(task.priority);
                        final color = _colorForPriority(task.priority);
                        return Draggable<Task>(
                          data: task,
                          feedback: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              width: MediaQuery.of(context).size.width / 2,
                              
                              padding: const EdgeInsets.all(16.0),
                              /** This is the display that get dragged  */
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.only(right: 8.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      task.name,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          /* Background widget that gets shown on the task section when a task is being dragged */
                          childWhenDragging: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            // child: ListTile(
                            //   title: Text(task.name, style: GoogleFonts.lexend(
                            //       textStyle: const TextStyle(
                            //         color: Colors.black,
                            //         fontSize: 13.0,
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     )),
                            //   subtitle: Text('Priority: $priorityString'),
                            //   contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            // ),
                            child: const ListTile(),
                            
                          ),

                          onDragStarted: () {

                            ref.read(tasksProvider.notifier).startDraggingTask(task);
                          },
                          onDraggableCanceled: (velocity, offset) {
                            ref.read(tasksProvider.notifier).cancelDraggingTask(task);
                          },

                          onDragEnd: (details) {
                            // print("-" + task.name);
                            // print(details.wasAccepted);
                            if (details.wasAccepted) {
                              setState(() {
                                ref.read(tasksProvider.notifier).refreshTasks();

                                tasks.remove(task);
                              });
                            }

                            //refreshTasks();

                            // print("reached here");
                            // for (int i = 0; i < tasks.length; i++) {
                            //   print(tasks[i].name);
                            // }
                            // print("");

                          },

                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ListTile(
                                
                              title: Text(task.name, style: GoogleFonts.lexend(
                                textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                              subtitle: Row(
                                children: [
                                  
                                  Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.only(right: 8.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color,
                                    ),
                                  ),
                                  Text('Priority: $priorityString')
                                ],
                              ),

                              contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("No tasks found", style: TextStyle(color: Colors.black)));
                  }
                },
              ),
            ),
            // CalendarSection(
            //   onTaskDropped: _onTaskDropped,
            // ),
        
        ]
      ),
    );
  }
}
