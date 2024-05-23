import 'package:flutter/material.dart';


/// A class representing a calendar event.
class CalendarEvent {
  String title;
  String note;
  DateTime startDateTime;
  DateTime endDateTime;
  int reminder;
  String priority;
  String expected_time_to_complete;
  String actual_time_to_complete;
  String recurrence;
  Color color;

  /// Creates a [CalendarEvent] instance.
  ///
  /// [title]: The title of the event.
  /// [note]: Additional notes for the event.
  /// [startDateTime]: The start date and time of the event.
  /// [endDateTime]: The end date and time of the event.
  /// [reminder]: The reminder time before the event starts, in minutes.
  /// [priority]: The priority of the event.
  /// [expected_time_to_complete]: The expected time to complete the event.
  /// [actual_time_to_complete]: The actual time taken to complete the event.
  /// [recurrence]: The recurrence pattern of the event.
  /// [color]: The color associated with the event.
  CalendarEvent({
    required this.title,
    required this.note,
    required this.startDateTime,
    required this.endDateTime,
    required this.reminder,
    required this.priority,
    required this.expected_time_to_complete,
    required this.actual_time_to_complete,
    required this.recurrence,
    required this.color,
    
  });

  /// Creates a [CalendarEvent] instance from a JSON object.
  ///
  /// [json]: The JSON object to parse.
  ///
  /// Returns the parsed [CalendarEvent] instance.
  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    /// Parses a color string into a [Color] object.
    ///
    /// [colorStr]: The color string to parse.
    ///
    /// Returns the parsed [Color] object.
    Color parseColor(String colorStr) {
      try {
        return Color(int.parse(colorStr));
      } catch (_) {
        return Colors.green; // Default color in case of parsing failure
      }
    } 

    /// Constructs a date-time string from a date and time.
    ///
    /// [date]: The date part of the string.
    /// [time]: The time part of the string.
    ///
    /// Returns the constructed date-time string.
    String constructDateTimeString(String date, String? time) {
      // Assign a default value if time is null or empty
      const defaultTime = "00:00:00";
      return 'T${time ?? defaultTime}';
    }

    return CalendarEvent(
      title: json['title'] as String? ?? "",
      note: json['note'] as String? ?? "",
      startDateTime: DateTime.parse(constructDateTimeString(json['date'], json['startTime'])),
      endDateTime: DateTime.parse(constructDateTimeString(json['date'], json['endTime'])),
      reminder: json['reminder'] as int? ?? 0,
      priority: json['priority'] as String? ?? "Low",
      recurrence: json['recurrence'] as String? ?? "1",
      color: parseColor(json['color'] as String? ?? '#fcba03'), 
      expected_time_to_complete: json['expected_time_to_complete'] as String? ?? "",
      actual_time_to_complete: json['actual_time_to_complete'] as String? ?? "",
    );
  }

  @override
  String toString() {
    return 'CalendarEvent(title: $title, startDateTime: $startDateTime, endDateTime: $endDateTime, reminder: $reminder, priority: $priority, recurrence: $recurrence, color: $color)';
  }
}