import 'package:flutter/material.dart';
import 'package:yinsight/Screens/HomePage/widgets/Calender/eventsCalender.dart';
import 'package:yinsight/Screens/Recall/views/recall_screen.dart';

import 'package:yinsight/Screens/Reflection/CardScreen.dart';
import 'package:yinsight/Screens/Streaks/FlipCard.dart';

/// A service to manage navigation between different screens.
class NavigationService {
  /// Navigates to the Reflection screen.
  ///
  /// [context]: The build context.
  static void navigateToReflection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CardScreen()),
    );
  }

  /// Navigates to the Recall screen.
  ///
  /// [context]: The build context.
  static void navigateToRecall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Recall()),
    );
  }

  /// Navigates to the Calendar screen.
  ///
  /// [context]: The build context.
  static void navigateToCalendar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GoogleCalendarClass()),
    );
  }

  /// Navigates to the Calendar screen.
  ///
  /// [context]: The build context.
  static void navigateToBadge(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FlipCardScreen()),
    );
  }
}
