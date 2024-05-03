import 'package:flutter/material.dart';
import 'package:yinsight/Screens/HomePage/widgets/Calender/eventsCalender.dart';
import 'package:yinsight/Screens/Recall/views/recall_screen.dart';

import 'package:yinsight/Screens/Reflection/CardScreen.dart';

class NavigationService {
  static void navigateToReflection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CardScreen()),
    );
  }

  static void navigateToRecall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Recall()),
    );
  }

  static void navigateToCalendar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GoogleCalendarClass()),
    );
  }
}
