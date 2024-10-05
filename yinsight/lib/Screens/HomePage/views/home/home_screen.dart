import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yinsight/Globals/services/userInfo.dart';
import 'package:yinsight/Screens/HomePage/services/navigation_service.dart';
import 'package:yinsight/Screens/HomePage/widgets/assignment_info_card.dart';
import 'package:yinsight/Screens/HomePage/widgets/avatar.dart';
import 'package:yinsight/Screens/HomePage/widgets/card_schedule_widget.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onSectionTap,
    });
  static const String id = 'Home_Screen';

  // go to either the Focus, Recall, or Reflect page, and update the bottom navigation bar
  final void Function(int index) onSectionTap;


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _animation;

  //get http => null;
  String activity = "userOpenedApp";

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    _setupAnimation();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkAndUpdatePoints());
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
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
      // print('Attempting to call URL: $url');
      // print('Token: $token'); // Print token for debugging

      final httpClient = HttpClient();
      try {
        final request = await httpClient.getUrl(Uri.parse(url));
        request.headers.set('Authorization', token);
        // print('Request headers: ${request.headers}'); // Print request headers

        final response = await request.close();
        // print("Response Status: ${response.statusCode}");

        final responseBody = await response.transform(utf8.decoder).join();
        // print("Response Body: $responseBody");

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
                pointsEarned == 1.0) {
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

      if (response.statusCode != 200) {
        throw Exception('Failed to update daily activity and streak');
      }
    } finally {
      httpClient.close();
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Checks if this is the user's first time opening the app.
  void _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = (prefs.getBool('isFirstTime') ?? true);

    if (isFirstTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog();
      });
      await prefs.setBool('isFirstTime', false);
    }
  }

  /// Shows a welcome dialog when the user opens the app for the first time.
  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Welcome!😀"),
          content: const Text("🗓️ Welcome to the Plan Section! 🗓️\n\n"
              "In this area, you can view all your tasks sorted by priority in the 'Task Notes' 📝.\n\n"
              "Ready to schedule? Simply drag and drop tasks from the list on the left into the calendar on the right.\n\n"),
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

  /// Fetches the number of tasks created by the user.
  ///
  /// Returns the total number of tasks created as an integer.
  Future<int> fetchNumberOfTasksCreated() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    if (token == null) {
      throw Exception('No token found');
    }
    final response = await http.get(
      Uri.parse(UserInformation.getRoute('NumberOfTasksCreated')),
      headers: {
        'Authorization': token,
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['total_number_of_tasks'];
    } else {
      throw Exception('Failed to load task count');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AvatarWidget(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: Text(
                      'Overview',
                      style: GoogleFonts.lexend(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      NavigationService.navigateToCalendar(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Year at a Glance',
                            style: GoogleFonts.lexend(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    const CardScheduleWidget(height: 400),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black),
                            ),
                            child: Column(
                              children: [
                                AssignmentInfoCard(
                                  title: 'Recall',
                                  content: 'Placeholder text for recall.',
                                  color: Colors.red,
                                  onTap: () => widget.onSectionTap(2),
                                ),
                                const SizedBox(height: 10),
                                AssignmentInfoCard(
                                  title: 'Focus',
                                  content: 'Placeholder text for focus.',
                                  color: Colors.green,
                                  onTap: () => widget.onSectionTap(1),
                                ),

                                // add the current number of tasks present for the user
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      FutureBuilder<int>(
                                        future: fetchNumberOfTasksCreated(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Text(
                                              snapshot.data.toString(),
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          } else if (snapshot.hasError) {
                                            return const Text(
                                              '?',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          } else {
                                            return const CircularProgressIndicator();
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Current Missions',
                                        style: GoogleFonts.lexend(
                                          textStyle: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),
                                AssignmentInfoCard(
                                  title: 'Reflect',
                                  content: 'Placeholder text for reflect.',
                                  color: Colors.blue,
                                  onTap: () => widget.onSectionTap(3),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Expanded(
                        //   child: Container(
                        //     padding: const EdgeInsets.all(10),
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(10),
                        //       border: Border.all(color: Colors.black),
                        //     ),
                        //     child: Column(
                        //       children: [
                        //         ProgressInfoCard(
                        //           title: 'Recall',
                        //           progress: 0.7,
                        //           color: Colors.red,
                        //           onTap: () => widget.onSectionTap(2),
                        //         ),
                        //         const SizedBox(height: 10),
                        //         ProgressInfoCard(
                        //           title: 'Focus',
                        //           progress: 0.5,
                        //           color: Colors.green,
                        //           onTap: () => widget.onSectionTap(1),
                        //         ),
                        //         const SizedBox(height: 10),
                        //         ProgressInfoCard(
                        //           title: 'Reflect',
                        //           progress: 0.9,
                        //           color: Colors.blue,
                        //           onTap: () => widget.onSectionTap(3),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),

                    const SizedBox(height: 10,),
                  ],
                ),
              ),

              const SizedBox(height: 10,),
            ],
          ),
        ),
      ),
    );
  }
}
