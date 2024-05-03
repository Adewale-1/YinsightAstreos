import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yinsight/Screens/HomePage/services/navigation_service.dart';
import 'package:yinsight/Screens/HomePage/widgets/avatar.dart';
import 'package:yinsight/Screens/HomePage/widgets/card_schedule_widget.dart';
import 'package:yinsight/Screens/Focus/views/focusCardOnHomePage.dart';
import 'package:yinsight/Screens/HomePage/widgets/recall_card.dart';
import 'package:yinsight/Screens/HomePage/widgets/reflection_card.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String id = 'Home_Screen';


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user  = FirebaseAuth.instance.currentUser;


  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

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
  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Welcome!😀"),
          content: const Text(
          "🗓️ Welcome to the Plan Section! 🗓️\n\n"
          "In this area, you can view all your tasks sorted by priority in the 'Task Notes' 📝.\n\n Ready to schedule? Simply drag and drop tasks from the list on the left into the calendar on the right.\n\n"
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

  
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AvatarWidget(), // Refactored to widgets/avatar.dart
              // ... other components
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Text('Overview',
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
                    const FocusCard(
                      height: 150),
                    const SizedBox(height: 20),// 2% of the screen height for spacing
                      Row(
                        children: [
                          Expanded(
                            child: RecallCard(
                              onTap: () => NavigationService.navigateToRecall(context),
                              height: screenHeight * 0.2, // 10% of the screen height
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02), // 2% of the screen width for spacing
                          Expanded(
                            child: ReflectionCard(
                              onTap: () => NavigationService.navigateToReflection(context),
                              cardHeight: screenHeight * 0.2, // 10% of the screen height
                              cardWidth: screenWidth * 0.45, // 45% of the screen width
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
