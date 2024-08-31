import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:yinsight/Screens/HomePage/services/navigation_service.dart';

class StreaksPage extends StatefulWidget {
  @override
  _StreaksPageState createState() => _StreaksPageState();
}

class _StreaksPageState extends State<StreaksPage> {
  // Example data - replace this with your backend data
  Map<DateTime, int> heatmapData = {
    DateTime(2024, 2, 1): 5,
    DateTime(2024, 2, 2): 2,
    DateTime(2024, 2, 3): 8,
    DateTime(2024, 2, 5): 10,
    DateTime(2024, 8, 1): 5,
    DateTime(2024, 8, 2): 2,
    DateTime(2024, 8, 3): 8,
    DateTime(2024, 8, 5): 10,
    DateTime(2024, 8, 18): 10,
    DateTime(2024, 8, 7): 5,
    DateTime(2024, 8, 8): 2,
    DateTime(2024, 8, 11): 8,
    DateTime(2024, 8, 31): 10,
    // Add more data points as needed
  };

  DateTime now = DateTime(2024, 2, 1);

  // Controller for the PageView
  PageController _pageController;
  int _currentPageIndex;

  // Selected year
  int _selectedYear;
  List<int> _years = [];

  _StreaksPageState()
      : _currentPageIndex =
            DateTime.now().month - 1, // Start with the current month
        _pageController = PageController(initialPage: DateTime.now().month - 1),
        _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _years = _getAvailableYears();
    _selectedYear = _years.first;
  }

  List<int> _getAvailableYears() {
    return heatmapData.keys.map((date) => date.year).toSet().toList()
      ..sort();
  }

  int getTotalActiveDays() {
    return heatmapData.keys.length;
  }

  int getMaxStreak() {
    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? previousDay;

    for (var day in heatmapData.keys.toList()..sort()) {
      if (previousDay != null &&
          day.difference(previousDay).inDays == 1) {
        currentStreak++;
      } else {
        currentStreak = 1;
      }

      if (currentStreak > maxStreak) {
        maxStreak = currentStreak;
      }

      previousDay = day;
    }

    return maxStreak;
  }

  Color getHeatmapColor(int value) {
    if (value == 0) return Colors.grey.withOpacity(0.5); // No data
    if (value <= 2) return Colors.green[100]!;
    if (value <= 5) return Colors.green[300]!;
    if (value <= 8) return Colors.green[500]!;
    print({now});
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
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   decoration: BoxDecoration(
                //     color: Colors.blue, // Blue background color
                //     borderRadius: BorderRadius.circular(10), // Rounded corners
                //     border: Border.all(
                //       color: Colors.blue, // Border color
                //     ),
                //   ),
                //   child: DropdownButtonHideUnderline(
                //     child: DropdownButton<int>(
                //       value: _selectedYear,
                //       items: _years.map((int year) {
                //         return DropdownMenuItem<int>(
                //           value: year,
                //           child: Text(
                //             year.toString(),
                //             style: GoogleFonts.lexend(
                //               color: Colors.white, // White text color
                //             ),
                //           ),
                //         );
                //       }).toList(),
                //       onChanged: (int? newYear) {
                //         setState(() {
                //           _selectedYear = newYear!;
                //         });
                //       },
                //       dropdownColor: Colors.blue, // Background color of the dropdown
                //       icon: const Icon(
                //         Icons.arrow_drop_down, // Dropdown arrow icon
                //         color: Colors.white, // Arrow color
                //       ),
                //     ),
                //   ),
                // ),

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
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
              //   children: [
              //     RichText(
              //       text: TextSpan(
              //         text: "Total Active Days: ",
              //         style: GoogleFonts.lexend(
              //           color: Colors.black54, // Normal text color
              //           fontSize: 16.0, // Normal font size
              //         ),
              //         children: [
              //           TextSpan(
              //             text: "${getTotalActiveDays()}",
              //             style: GoogleFonts.lexend(
              //               color: Colors.black, // Bold value color
              //               fontSize: 20.0, // Larger font size for the value
              //               fontWeight: FontWeight.bold, // Bold font weight
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //     RichText(
              //       text: TextSpan(
              //         text: "Max Streak: ",
              //         style: GoogleFonts.lexend(
              //           color: Colors.black54, // Normal text color
              //           fontSize: 16.0, // Normal font size
              //         ),
              //         children: [
              //           TextSpan(
              //             text: "${getMaxStreak()}",
              //             style: GoogleFonts.lexend(
              //               color: Colors.black, // Bold value color
              //               fontSize: 20.0, // Larger font size for the value
              //               fontWeight: FontWeight.bold, // Bold font weight
              //             ),
              //           ),
              //           TextSpan(
              //             text: " days",
              //             style: GoogleFonts.lexend(
              //               color: Colors.black54, // Normal text color
              //               fontSize: 16.0, // Normal font size
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
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
                                  // child: Stack(
                                  //   children: [
                                  //     Positioned(
                                  //       bottom: 4,
                                  //       left: 4,
                                  //       child: Text(
                                  //         dayNumber.toString(),
                                  //         style: const TextStyle(
                                  //           color: Colors.black54,
                                  //           fontSize: 12,
                                  //           fontWeight: FontWeight.bold,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //     // Other content can be added here if needed
                                  //   ],
                                  // ),
                                  // child: Center(
                                  //     // child: Text(
                                  //     //   dayNumber.toString(),
                                  //     //   style: const TextStyle(
                                  //     //     color: Colors.black54,
                                  //     //     fontWeight: FontWeight.bold,
                                  //     //   ),
                                  //     // ),
                                  //     ),
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
              // const SizedBox(height: 20),
              // Container(
              //   height: 200,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(15),
              //     color: Colors.white,
              //     border: Border.all(width: 1, color: Colors.black12),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.grey.withOpacity(0.5),
              //         spreadRadius: 2,
              //         blurRadius: 4,
              //         offset: const Offset(0, 3),
              //       ),
              //     ],
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.stretch,
              //     children: [
              //       Padding(
              //         padding: const EdgeInsets.all(16.0),
              //         child: Text(
              //           "Community Stats",
              //           style: GoogleFonts.lexend(
              //             textStyle: const TextStyle(
              //               fontSize: 20,
              //               fontWeight: FontWeight.bold,
              //               color: Colors.black,
              //             ),
              //           ),
              //           textAlign: TextAlign.center,
              //         ),
              //       ),
              //       const Divider(height: 1, thickness: 1, color: Colors.black),
              //       Expanded(
              //         child: Padding(
              //           padding: const EdgeInsets.all(16.0),
              //           child: Column(
              //             mainAxisAlignment: MainAxisAlignment.spaceAround,
              //             children: [
              //               _buildStatsRow(
              //                   "Invite friends",
              //                   Icons.people_outline,
              //                   Colors.blue,
              //                   "10 points"), // Placeholder value
              //               _buildStatsRow(
              //                   "Review other users",
              //                   Icons.star_border,
              //                   Colors.orange,
              //                   "5 points"), // Placeholder value
              //               _buildStatsRow(
              //                   "Complete tasks",
              //                   Icons.check_circle_outline,
              //                   Colors.green,
              //                   "15 points"), // Placeholder value
              //               _buildStatsRow(
              //                   "Share progress",
              //                   Icons.share,
              //                   Colors.purple,
              //                   "20 points"), // Placeholder value
              //             ],
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildStatsRow(
  //     String label, IconData icon, Color color, String value) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Row(
  //         children: [
  //           Icon(
  //             icon,
  //             color: color,
  //           ),
  //           const SizedBox(width: 8),
  //           Text(
  //             label,
  //             style: GoogleFonts.lexend(
  //               color: Colors.black,
  //               fontSize: 16.0,
  //             ),
  //           ),
  //         ],
  //       ),
  //       Text(
  //         value,
  //         style: GoogleFonts.lexend(
  //           color: Colors.black,
  //           fontWeight: FontWeight.bold,
  //           fontSize: 16.0,
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
