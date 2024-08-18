import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:yinsight/Screens/HomePage/services/navigation_service.dart'; // Import to format the month name

class StreaksPage extends StatefulWidget {
  @override
  _StreaksPageState createState() => _StreaksPageState();
}

class _StreaksPageState extends State<StreaksPage> {
  List<bool> completedDays =
      List.generate(31, (index) => false); // Example data

  double focusProgress = 0.7; // Example progress value
  double recallProgress = 0.5; // Example progress value

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
                // Change this from Expanded to Container
                height: 400, // Set the height to 350
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
                  itemCount: 12, // Number of months to show
                  itemBuilder: (context, monthIndex) {
                    int year = DateTime.now().year;
                    int daysInMonth = DateTime(year, monthIndex + 2, 0).day;

                    String monthName = DateFormat.MMMM()
                        .format(DateTime(year, monthIndex + 1));

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 5),
                          child: Text(
                            monthName, // Display the month name
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7, // 7 days in a week
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                              itemCount:
                                  daysInMonth, // Correct number of days in the month
                              itemBuilder: (context, dayIndex) {
                                bool isCompleted =
                                    completedDays[dayIndex]; // Example data
                                return Container(
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? Colors.deepPurpleAccent
                                        : Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
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
              // const SizedBox(
              //   height: 10, // Reduced height to make it more compact
              // ),

              // // "Today" Section
              // const Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 16.0),
              //   child: Align(
              //     alignment: Alignment.centerLeft,
              //     child: Text(
              //       "Today",
              //       style: TextStyle(
              //         fontSize:
              //             20, // Slightly reduce font size to better match a compact design
              //         fontWeight: FontWeight.bold,
              //         color: Colors.black,
              //       ),
              //     ),
              //   ),
              // ),
              // const SizedBox(
              //   height: 10, // Reduced height to make it more compact
              // ),

              // // Focus Section
              // Padding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       const Text(
              //         "Focus",
              //         style: TextStyle(
              //           fontSize: 18, // Slightly reduce font size
              //           fontWeight: FontWeight
              //               .w500, // Adjust weight for visual consistency
              //           color: Colors.black,
              //         ),
              //       ),
              //       const SizedBox(
              //         height:
              //             8, // Add a little space between text and progress bar
              //       ),
              //       LinearProgressIndicator(
              //         value: focusProgress,
              //         minHeight:
              //             5, // Thinner progress bar to match compact design
              //         backgroundColor: Colors.grey[
              //             300], // Adjust background color for better contrast
              //         valueColor: const AlwaysStoppedAnimation<Color>(
              //             Colors.blue), // Custom progress color
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(
              //   height: 10, // Reduced height to keep spacing consistent
              // ),

              // // Recall Section
              // Padding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       const Text(
              //         "Recall",
              //         style: TextStyle(
              //           fontSize: 18, // Match the Focus section for consistency
              //           fontWeight: FontWeight.w500, // Adjust weight
              //           color: Colors.black,
              //         ),
              //       ),
              //       const SizedBox(
              //         height:
              //             8, // Add a little space between text and progress bar
              //       ),
              //       LinearProgressIndicator(
              //         value: recallProgress,
              //         minHeight: 5, // Thinner progress bar
              //         backgroundColor:
              //             Colors.grey[300], // Adjust background color
              //         valueColor: const AlwaysStoppedAnimation<Color>(
              //             Colors.green), // Custom progress color
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
}
