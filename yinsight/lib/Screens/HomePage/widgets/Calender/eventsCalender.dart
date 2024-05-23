import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:yinsight/Globals/services/userInfo.dart';
import 'package:yinsight/Screens/HomePage/widgets/Calender/model/calender_model.dart';
import 'package:yinsight/Screens/HomePage/widgets/Calender/services/calenderService.dart';


/// A screen that displays events from Google Calendar.
class GoogleCalendarClass extends StatefulWidget {
  const GoogleCalendarClass({super.key});

  @override
  _GoogleCalendarClassState createState() => _GoogleCalendarClassState();
}

class _GoogleCalendarClassState extends State<GoogleCalendarClass> {
  List<CalendarEvent> _events = [];

  @override
  void initState() {
    super.initState();
    fetchCalendarEvents();
  }

  /// Cleans up the date string.
  ///
  /// [dateString]: The date string to clean.
  ///
  /// Returns the cleaned date string.
  String cleanDateString(String dateString) {
    // First, normalize the string by ensuring only one UTC identifier is present
    if (dateString.endsWith('Z')) {
      // Remove Z if +00:00 is also present anywhere in the string
      dateString = dateString.replaceAll('+00:00', '');
    } else if (dateString.contains('+00:00')) {
      // If Z is not present but +00:00 is, remove +00:00 and add Z for consistency
      dateString = '${dateString.replaceAll('+00:00', '')}Z';
    }
    return dateString;
  }

  /// Parses a date-time string to a [DateTime] object.
  ///
  /// [dateString]: The date-time string to parse.
  ///
  /// Returns the parsed [DateTime] object.
  DateTime parseDateTime(String dateString) {
    String? val;
    try {
      String cleanedDate = cleanDateString(dateString);
      val = cleanedDate;
      return DateTime.parse(cleanedDate);
    } catch (e) {
      // print('Failed to parse date: $dateString after cleaning to: $val, Error: $e');
      // It might be useful to rethrow the error to see where it breaks in development
      rethrow;
    }
  }


  /// Fetches calendar events from the backend.
  Future<void> fetchCalendarEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    String? token = await user?.getIdToken();
    // print("Fetching calendar events...");

    if (token == null) {
      // print('No token found');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(UserInformation.getRoute('getAllEventsFromUploadedCalendar')),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> eventsJson = json.decode(response.body)['uploadedCalendarEvents'];
        // print("Events content: $eventsJson");
        List<CalendarEvent> loadedEvents = [];

        for (var e in eventsJson) {
          final colorString = e['color'] as String? ?? '#0096FF'; // Default color
          final parsedColor = int.tryParse(colorString.substring(1), radix: 16) ?? 0x0096FF;
          final finalColor = parsedColor + 0xFF000000;

          final newEvent = CalendarEvent(
            title: e['title'] as String? ?? 'No Title',
            note: e['note'] as String? ?? '',
            startDateTime: parseDateTime(e['date'] + ' ' + (e['startTime'] as String? ?? '00:00:00')),
            endDateTime: parseDateTime(e['date'] + ' ' + (e['endTime'] as String? ?? '23:59:59')),
            reminder: (e['reminder'] as num?)?.toInt() ?? 0,
            priority: e['priority'] as String? ?? 'Low',
            expected_time_to_complete: (e['expected_time_to_complete'] as String?) ?? "",
            actual_time_to_complete: (e['actual_time_to_complete'] as String?) ?? "",
            recurrence: e['recurrence'] as String? ?? "1",
            color: Color(finalColor),
          );

          loadedEvents.add(newEvent);

          // Expand recurring events
          if (newEvent.recurrence != "1") {
            // print("Expanding recurrence for event: ${newEvent.title}");
            loadedEvents.addAll(expandRecurringEvents(newEvent));
          }
        }

        setState(() {
          _events = loadedEvents;
        });
        // print("Loaded events: $_events");
        // print("Total events loaded, including expanded: ${_events.length}");
        // // Writing to a file
        // final file = File('/Users/adewaleadenle/Software Development/GitHub Projects/Yinsight/yinsight/lib/Globals/events.txt');
        // final sink = file.openWrite(mode: FileMode.writeOnlyAppend);
        // for (var event in loadedEvents) {
        //   sink.writeln('Title: ${event.title},StartTime: ${event.startDateTime}, EndTime: ${event.endDateTime}, Note: ${event.note},Reminder: ${event.reminder},Priority: ${event.priority},ETC: ${event.expected_time_to_complete},ATC: ${event.actual_time_to_complete},Recurrence: ${event.recurrence}');
        // }
        // print('Events written to file named events.txt with path: ${file.path}');
        // await sink.flush();
        // await sink.close();

      } else {
        // print('Failed to load events with status code: ${response.statusCode}');
      }
    } catch (e) {
      // print('Failed to load events with error: $e');
    }
  }
  
  /// Expands recurring events.
  ///
  /// [recurringEvent]: The recurring event to expand.
  ///
  /// Returns a list of expanded events.
  List<CalendarEvent> expandRecurringEvents(CalendarEvent recurringEvent) {
      List<CalendarEvent> expandedEvents = [];
      Map<String, List<String>> recurrenceRules = parseRecurrence(recurringEvent.recurrence);
      DateTime untilDate = recurrenceRules.containsKey('UNTIL') ? DateTime.parse(recurrenceRules['UNTIL']!.first) : DateTime(2024); // Fallback date
      List<String> byDays = recurrenceRules.containsKey('BYDAY') ? recurrenceRules['BYDAY']! : [];

      // print("BYDAYS: $byDays");

      DateTime currentDate = recurringEvent.startDateTime;
      while (currentDate.isBefore(untilDate.add(const Duration(days: 1)))) {
          final weekdayString = _weekdayToString(currentDate.weekday);

          // Check if daily recurrence is specified or if BYDAY is not set
          if (recurrenceRules['FREQ']?.contains('DAILY') ?? false || byDays.isEmpty) {
              final newEvent = CalendarEvent(
                  title: recurringEvent.title,
                  note: recurringEvent.note,
                  startDateTime: DateTime(currentDate.year, currentDate.month, currentDate.day,
                                          recurringEvent.startDateTime.hour, recurringEvent.startDateTime.minute),
                  endDateTime: DateTime(currentDate.year, currentDate.month, currentDate.day,
                                        recurringEvent.endDateTime.hour, recurringEvent.endDateTime.minute),
                  reminder: recurringEvent.reminder,
                  priority: recurringEvent.priority,
                  recurrence: "1", // Clear recurrence to avoid infinite loop
                  color: recurringEvent.color,
                  expected_time_to_complete: recurringEvent.expected_time_to_complete,
                  actual_time_to_complete: recurringEvent.actual_time_to_complete,
              );
              expandedEvents.add(newEvent);
          }
          currentDate = currentDate.add(const Duration(days: 1));
      }
      // print("Expanded events: $expandedEvents");
      return expandedEvents;
  }
  /// Parses the recurrence string into a map.
  ///
  /// [recurrence]: The recurrence string to parse.
  ///
  /// Returns a map of recurrence rules.

  Map<String, List<String>> parseRecurrence(String recurrence) {
      Map<String, List<String>> rules = {};
      var parts = recurrence.split(';');
      for (var part in parts) {
          var keyVal = part.split('=');
          if (keyVal.length == 2) {
              rules[keyVal[0]] = keyVal[1].split(',');
          }
      }
      return rules;
  }
  /// Converts a weekday integer to a string.
  ///
  /// [weekday]: The weekday integer.
  ///
  /// Returns the weekday string.
  String _weekdayToString(int weekday) {
    switch (weekday) {
      case DateTime.monday: return "MO";
      case DateTime.tuesday: return "TU";
      case DateTime.wednesday: return "WE";
      case DateTime.thursday: return "TH";
      case DateTime.friday: return "FR";
      case DateTime.saturday: return "SA";
      case DateTime.sunday: return "SU";
      default: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Calendar'),
      ),
      body: SfCalendar(
        view: CalendarView.month,
        dataSource: EventDataSource(_events),
        monthViewSettings: const MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment, showAgenda: true
        ),
        
      ),
    );
  }
}