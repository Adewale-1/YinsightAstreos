import 'package:flutter/material.dart';

/// Enum for the task priority levels.
enum TaskPriority { low, medium, high }

/// A class representing a task.
class Task {
  final String id;
  final String name;
  final String notes;
  final TaskPriority priority;
  final DateTime? assignedDate;
  final DateTime? assignedTime; 
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  final String? expectedTimeToComplete; 
  final String? actualTimeToComplete;
  final String? totalTimeSpent;
  final String? recurrence;

  /// Creates a [Task] instance.
  ///
  /// [id]: The unique identifier of the task.
  /// [name]: The name of the task.
  /// [notes]: Additional notes for the task.
  /// [priority]: The priority level of the task.
  /// [assignedDate]: The date the task is assigned.
  /// [assignedTime]: The specific datetime the task is scheduled for.
  /// [startTime]: The start time of the task.
  /// [endTime]: The end time of the task.
  /// [expectedTimeToComplete]: The expected time to complete the task.
  /// [actualTimeToComplete]: The actual time taken to complete the task.
  /// [totalTimeSpent]: The total time spent on the task.
  /// [recurrence]: The recurrence pattern of the task.
  Task({
    required this.id,
    required this.name,
    required this.notes,
    required this.priority, // Directly use TaskPriority enum
    this.assignedDate,
    this.assignedTime,
    this.startTime,
    this.endTime,
    this.expectedTimeToComplete, // Updated variable name
    this.actualTimeToComplete,
    this.totalTimeSpent,
    this.recurrence,
  });

  // Helper function to convert priority string to enum
  static TaskPriority _priorityFromString(String value) {
    switch (value.toLowerCase()) {
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      default:
        return TaskPriority.low;
    }
  }
  Task copyWith({
      String? id,
      String? name,
      String? notes,
      TaskPriority? priority,
      DateTime? assignedDate,
      DateTime? assignedTime,
      TimeOfDay? startTime,
      TimeOfDay? endTime,
      String? expectedTimeToComplete, // Updated variable name
      String? actualTimeToComplete,
      String? totalTimeSpent,
      String? recurrence,
    }) {
      return Task(
        id: id ?? this.id,
        name: name ?? this.name,
        notes: notes ?? this.notes,
        priority: priority ?? this.priority, // Priority is already a TaskPriority enum
        assignedDate: assignedDate ?? this.assignedDate,
        assignedTime: assignedTime ?? this.assignedTime,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,

        expectedTimeToComplete: expectedTimeToComplete ?? this.expectedTimeToComplete,
        actualTimeToComplete: actualTimeToComplete ?? this.actualTimeToComplete,
        totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
        recurrence: recurrence ?? this.recurrence,
      );
    }
  /// Converts the task instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'priority': priority.toString().split('.').last, // Converts enum to string
      'assignedDate': assignedDate?.toIso8601String(),
      'assignedTime': assignedTime?.toIso8601String(),
      'startTime': startTime != null ? '${startTime!.hour}:${startTime!.minute}' : null,
      'endTime': endTime != null ? '${endTime!.hour}:${endTime!.minute}' : null,

      'expectedTimeToComplete': expectedTimeToComplete,
      'actualTimeToComplete': actualTimeToComplete,
      'totalTimeSpent': totalTimeSpent,
      'recurrence': recurrence,
    };
  }

  /// Creates a [Task] instance from a JSON object.
  ///
  /// [json]: The JSON object to parse.
  ///
  /// Returns the parsed [Task] instance.
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      name: json['name'] as String,
      notes: json['notes'] as String,
      // priority: _priorityFromString(json['priority'] as String), // Use the conversion method here
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
        orElse: () => TaskPriority.low, // Default to low if not found
      ),
      assignedDate: json['assignedDate'] != null ? DateTime.tryParse(json['assignedDate']) : null,
      assignedTime: json['assignedTime'] != null ? DateTime.tryParse(json['assignedTime']) : null,
      startTime: _parseTimeOfDay(json['startTime']),
      endTime: _parseTimeOfDay(json['endTime']),

      expectedTimeToComplete: json['expectedTimeToComplete'],
      actualTimeToComplete: json['actualTimeToComplete'],
      totalTimeSpent: json['totalTimeSpent'],
      recurrence: json['recurrence'],
    );
  }

  // Helper method to parse a string into TimeOfDay, returns null if the string is null or bad format
  static TimeOfDay? _parseTimeOfDay(String? timeString) {
    if (timeString == null) return null;
    final parts = timeString.split(':').map((e) => int.tryParse(e)).toList();
    if (parts.length != 2 || parts.contains(null)) return null;
    return TimeOfDay(hour: parts[0]!, minute: parts[1]!);
  }
}
