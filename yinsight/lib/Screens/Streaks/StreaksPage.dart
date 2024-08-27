import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yinsight/Globals/services/userInfo.dart';
import 'package:yinsight/Screens/HomePage/services/navigation_service.dart';

class StreaksPage extends StatefulWidget {
  const StreaksPage({super.key});

  @override
  _StreaksPageState createState() => _StreaksPageState();
}

class _StreaksPageState extends State<StreaksPage> {
  Map<DateTime, int> heatmapData = {};

  // DateTime now = DateTime(2024, 2, 1);

  // Controller for the PageView
  final PageController _pageController;
  int _currentPageIndex;

  _StreaksPageState()
      : _currentPageIndex =
            DateTime.now().month - 1, // Start with the current month
        _pageController = PageController(initialPage: DateTime.now().month - 1);

  @override
  void initState() {
    super.initState();
    _getStreaksMap(); // Fetch streaks data when the page is initialized
  }

  Future<void> _getStreaksMap() async {
    final user = FirebaseAuth.instance.currentUser;
    String? token = await user?.getIdToken();
    if (token == null) throw Exception('No token found');

    var response = await http.get(
      Uri.parse(UserInformation.getRoute('entireStreaks')),
      headers: {'Authorization': token},
    );

    if (response.statusCode != 200) throw Exception('Failed to load tasks');

    var data = jsonDecode(response.body);
    if (data['message'] != 'Successfully retrieved points for the calendar.') {
      throw Exception('Unexpected response message');
    }

    Map<String, dynamic> calendarPoints = data['calendar_points'];
    setState(() {
      heatmapData = calendarPoints.map((dateString, value) {
        DateTime date = DateTime.parse(dateString);
        return MapEntry(date, value.toInt());
      });
    });
  }

  Color getHeatmapColor(int value) {
    if (value == 0) return Colors.grey.withOpacity(0.5); // No data
    if (value <= 2) return Colors.green[100]!;
    if (value <= 5) return Colors.green[300]!;
    if (value <= 8) return Colors.green[800]!;
    return Colors.green[700]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      NavigationService.navigateToBadge(context);
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
                            'Badge',
                            style: GoogleFonts.lexend(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.local_police,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  border: Border.all(width: 1, color: Colors.black12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount:
                      DateTime.now().month, // Only up to the current month
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  itemBuilder: (context, monthIndex) {
                    int year = DateTime.now().year;
                    DateTime firstDayOfMonth =
                        DateTime(year, monthIndex + 1, 1);
                    int daysInMonth = DateTime(year, monthIndex + 2, 0).day;

                    String monthName =
                        DateFormat.MMMM().format(firstDayOfMonth);

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 5),
                          child: Text(
                            monthName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                              .map((day) => Text(day,
                                  style: const TextStyle(color: Colors.black)))
                              .toList(),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                              itemCount: 42, // 6 weeks * 7 days
                              itemBuilder: (context, index) {
                                int dayNumber =
                                    index - firstDayOfMonth.weekday + 1;
                                if (dayNumber < 1 || dayNumber > daysInMonth) {
                                  return Container(); // Empty container for days outside the month
                                }
                                DateTime currentDate =
                                    DateTime(year, monthIndex + 1, dayNumber);
                                int value = heatmapData[currentDate] ?? 0;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: getHeatmapColor(value),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                      // child: Text(
                                      //   dayNumber.toString(),
                                      //   style: const TextStyle(
                                      //     color: Colors.black54,
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      // ),
                                      ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
