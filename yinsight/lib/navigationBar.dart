import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:yinsight/Screens/Focus/views/focus.dart';
import 'package:yinsight/Screens/HomePage/views/home/home_screen.dart';
import 'package:yinsight/Screens/HomePage/widgets/settings.dart';
import 'package:yinsight/Screens/Recall/views/recall_screen.dart';
import 'package:yinsight/Screens/Reflection/CardScreen.dart';
import 'package:yinsight/Screens/Streaks/StreaksPage.dart';

/// The main navigation screen of the application.
class MainNavigationScreen extends StatefulWidget {
  /// The identifier for the main navigation screen.
  static const String id = 'main_navigation_screen';

  /// Creates a [MainNavigationScreen] widget.
  const MainNavigationScreen({super.key});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // late final List<Widget> _screens = [
  //   const HomeScreen(),
  //   const focusSection(),
  //   const Recall(), // Ensure this is the correct class name
  //   const CardScreen(),
  //   const SettingsScreen(),
  // ];

  late final List<Widget> _screens = [
    HomeScreen(onSectionTap: _navigateToSection), // Pass the callback
    const focusSection(),
    const Recall(),
    const CardScreen(),
    const StreaksPage(),
    const SettingsScreen(),
  ];

  void _navigateToSection(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _currentIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.lightbulb_outline, size: 30, color: Colors.white),
          Icon(Icons.book, size: 30, color: Colors.white),
          Icon(Icons.sentiment_satisfied_alt, size: 30, color: Colors.white),
          Icon(Icons.calendar_month, size: 30, color: Colors.white),
          Icon(Icons.settings, size: 30, color: Colors.white),
        ],
        color: Colors.grey[800]!, // Ensure this is the desired color
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors
            .grey[850], // Ensure this is the desired button background color
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) => setState(() => _currentIndex = index),
        letIndexChange: (index) => true,
      ),
    );
  }
}
