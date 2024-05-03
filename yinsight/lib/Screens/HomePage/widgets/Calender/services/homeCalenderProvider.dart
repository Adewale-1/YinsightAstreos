// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:yinsight/lib/Screens/HomePage/widgets/Calender/homeScreenCalender.dart';

// final selectedDateProvider = StateProvider.autoDispose<DateTime>((ref) {
//   DateTime now = DateTime.now();
//   WidgetsBinding.instance!.addPostFrameCallback((_) {
//     ref.read(calendarTasksProvider.notifier).fetchTasksForSelectedDay(now);
//   });
//   return now;
// });
