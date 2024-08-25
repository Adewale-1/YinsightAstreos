import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yinsight/Globals/services/userInfo.dart';
import 'package:yinsight/Screens/Focus/services/focus_services.dart';
import 'package:yinsight/Screens/Focus/services/timer_service.dart';
import 'package:yinsight/Screens/Focus/utils/task_utils.dart';
import 'package:yinsight/Screens/Focus/widgets/task_timer.dart';

class focusSection extends StatefulWidget {
  const focusSection({Key? key}) : super(key: key);

  @override
  State<focusSection> createState() => focusSectionState();
}

class focusSectionState extends State<focusSection>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusService _focusService = FocusService();
  final TimerService _timerService = TimerService();

  List<String> allTasks = [];
  List<String> displayedTasks = [];
  Map<String, String> taskIds = {};
  Map<String, Duration> taskElapsedTimes = {};
  Map<String, bool> taskStatus = {};
  Map<String, String> expectedTimes = {};
  Map<String, bool> taskCompletionStatus = {};

  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _animation;

  String activity = "taskCompletion";

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _searchController.addListener(_updateDisplayedTasks);
    _checkFirstTime();
    _setupAnimation();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _timerService.stopAllTimers();
    _updateAllTaskTimes();
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  Future<void> _fetchTasks() async {
    try {
      final tasksWithIds = await _focusService.fetchTasks();
      setState(() {
        allTasks = [];
        taskIds = {};
        for (var taskWithId in tasksWithIds) {
          var taskName = taskWithId['name'];
          var taskId = taskWithId['id'];
          var expectedTime = taskWithId['expectedTimeToComplete'] ?? '00:00';
          if (taskName != null && taskId != null) {
            allTasks.add(taskName);
            taskIds[taskName] = TaskUtils.extractTaskId(taskId);
            expectedTimes[taskName] = expectedTime;
          } else {
            print("Warning: Found task with null name or id");
          }
        }
        _fetchElapsedTimes();
        _updateDisplayedTasks();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchElapsedTimes() async {
    for (var task in allTasks) {
      var taskId = taskIds[task];
      if (taskId != null) {
        try {
          final totalTimeSpent =
              await _focusService.fetchTotalTimeSpent(taskId);
          final duration = TaskUtils.parseDuration(totalTimeSpent);
          setState(() {
            taskElapsedTimes[task] = duration;
            taskStatus[task] = false;
            taskCompletionStatus[task] = false;
          });
        } catch (e) {
          print(e);
        }
      }
    }
  }

  void _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTimeFocus') ?? true;
    if (isFirstTime) {
      prefs.setBool('isFirstTimeFocus', false);
      _showWelcomeDialog();
    }
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Let's go! 🚀"),
          content: const Text("🎯 Welcome to the Focus Section! 🎯\n\n"
              "Here, you can check out all your tasks along with their estimated completion times 🕘. This handy section helps you track the actual duration each task takes. Need to find something quickly? Just use the search bar 🔎 to zero in on any task.\n\n"
              "And hey, if you need to take a breather 🥱, no worries! The time you've already put in will be safely saved. So, take your time and focus on what matters!"),
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

  void _updateDisplayedTasks() {
    setState(() {
      displayedTasks = allTasks
          .where((task) =>
              task.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _toggleTaskStatus(String taskName) {
    setState(() {
      taskStatus[taskName] = !(taskStatus[taskName] ?? false);
    });

    if (taskStatus[taskName] ?? false) {
      _timerService.startTimer(
          taskName,
          (elapsedTime) => _updateElapsedTime(taskName, elapsedTime),
          taskElapsedTimes[taskName]!);
    } else {
      _timerService.pauseTimer(taskName);
    }
  }

  void _updateElapsedTime(String taskName, Duration elapsedTime) {
    setState(() {
      taskElapsedTimes[taskName] = elapsedTime;
    });
  }

  Future<bool> _showDeleteConfirmationDialog(String task) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Complete Task'),
          content: Text('Have you completed "$task"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
                setState(() {
                  taskCompletionStatus[task] = false;
                });
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                _completeTask(task);
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  Future<void> _completeTask(String task) async {
    var taskId = taskIds[task];
    if (taskId != null) {
      _timerService.stopTimer(task);
      try {
        await _focusService.deleteTask(taskId, () async {
          await _checkAndUpdatePoints();
        });
        setState(() {
          allTasks.remove(task);
          taskElapsedTimes.remove(task);
          taskStatus.remove(task);
          taskIds.remove(task);
          taskCompletionStatus.remove(task);
          _updateDisplayedTasks();
        });
      } catch (e) {
        print(e);
      }
    }
  }

  void _onCheckboxChanged(String taskName, bool? value) async {
    if (value != null) {
      setState(() {
        if (value) {
          taskCompletionStatus[taskName] = true;
          _showDeleteConfirmationDialog(taskName);
        }
      });
    }
  }

  Future<void> _updateDailyActivityAndStreak() async {
    final user = FirebaseAuth.instance.currentUser;
    String? token = await user?.getIdToken();

    if (token == null) {
      throw Exception('No token found');
    }

    final httpClient = HttpClient();
    try {
      final request = await httpClient
          .postUrl(Uri.parse(UserInformation.getRoute('allocatePoints')));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, token);
      request.add(utf8.encode(json.encode({'activity': activity})));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      print("The response body is: $responseBody");
      if (response.statusCode != 200) {
        throw Exception('Failed to update daily activity and streak');
      }
    } finally {
      httpClient.close();
    }
  }

  Future<void> _checkAndUpdatePoints() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      String? token = await user?.getIdToken();
      if (token == null) {
        print("No token found");
        return;
      }

      final url =
          '${UserInformation.getRoute('checkForPoints')}/?activity=$activity';

      final httpClient = HttpClient();
      try {
        final request = await httpClient.getUrl(Uri.parse(url));
        request.headers.set('Authorization', token);

        final response = await request.close();

        final responseBody = await response.transform(utf8.decoder).join();

        if (response.statusCode == 200) {
          final data = json.decode(responseBody);
          final pointsEarned = data['points_earned'];
          final lastOpenedDateTime = data['dateOfLastActivity'];

          if (lastOpenedDateTime != null) {
            final lastOpenedDate = DateTime.parse(lastOpenedDateTime).toLocal();
            final currentDate = DateTime.now().toLocal();
            print("Points earned is : $pointsEarned");
            print("Current date is $currentDate");
            print(
                "Difference is : ${currentDate.difference(lastOpenedDate).inDays}");
            if (currentDate.difference(lastOpenedDate).inDays == 0 &&
                pointsEarned >= 3.0) {
              print('Points already allocated today, not showing animation');
              return;
            }
          }

          print('Updating daily activity and showing animation');
          await _updateDailyActivityAndStreak();
          _showTransitionGif();
        } else {
          print('Failed to check points: ${response.statusCode}');
          print('Response body: $responseBody');
        }
      } finally {
        httpClient.close();
      }
    } catch (e, stackTrace) {
      print('Error checking points: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _showTransitionGif() {
    _overlayEntry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5 * _animation.value),
              child: Center(
                child: Image.asset(
                  'lib/Assets/Image_Comp/Icons/singleCoin.gif',
                  width: 100 + (50 * _animation.value),
                  height: 100 + (50 * _animation.value),
                ),
              ),
            ),
          );
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _animationController.reverse().then((_) {
          _overlayEntry?.remove();
          _overlayEntry = null;
        });
      });
    });
  }

  Future<void> _updateAllTaskTimes() async {
    for (var task in allTasks) {
      var taskId = taskIds[task];
      if (taskId != null) {
        try {
          final time = TaskUtils.formatDuration(taskElapsedTimes[task]!);
          await _focusService.updateTotalTimeSpent(taskId, time);
        } catch (e) {
          print(e);
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _timerService.saveTimersState();
    } else if (state == AppLifecycleState.resumed) {
      _timerService.restoreTimersState(_updateElapsedTime);
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
            child: ListView.builder(
              itemCount: displayedTasks.length,
              itemBuilder: (context, index) {
                final taskName = displayedTasks[index];
                final elapsedTime = taskElapsedTimes[taskName] ?? Duration.zero;
                final actualTime = TaskUtils.formatDuration(elapsedTime);
                final expectedTime = TaskUtils.formatTimeToHoursAndMinutes(
                    expectedTimes[taskName] ?? '00:00');
                final isChecked = taskCompletionStatus[taskName] ?? false;

                return TaskTimer(
                  task: taskName,
                  actualTime: actualTime,
                  expectedTime: expectedTime,
                  isRunning: taskStatus[taskName] ?? false,
                  isChecked: isChecked,
                  onStart: () => _toggleTaskStatus(taskName),
                  onPause: () => _toggleTaskStatus(taskName),
                  onCheckboxChanged: (bool? value) {
                    _onCheckboxChanged(taskName, value);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
