

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:yinsight/Globals/services/userInfo.dart';
import 'package:yinsight/Screens/HomePage/widgets/Calender/model/calender_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class EventDataSource extends CalendarDataSource {
  EventDataSource(List<CalendarEvent> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return (appointments![index] as CalendarEvent).startDateTime;
  }

  @override
  DateTime getEndTime(int index) {
    return (appointments![index] as CalendarEvent).endDateTime;
  }

  @override
  String getSubject(int index) {
    return (appointments![index] as CalendarEvent).title;
  }

  @override
  Color getColor(int index) {
    return (appointments![index] as CalendarEvent).color;
  }
}


 final getDateFilteredTasksProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, date) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    var url = Uri.parse(UserInformation.getRoute('getDateFilteredTasksInHomeCalendar?date=$date'));
    if (token == null) throw Exception('No token found');

    var response = await http.get(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },

    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['tasks'] as List).cast<Map<String, dynamic>>();
    } else {
      // Handle error scenarios
      throw Exception('Failed to fetch tasks: ${response.body}');
    }
  });
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());


