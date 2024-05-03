// import 'package:json_annotation/json_annotation.dart';

// part 'task_model.g.dart';

// @JsonSerializable()
// class Task {
//   final String? notes;
//   @JsonKey(name: 'assignedDate')
//   final DateTime? assignedDate;
//   @JsonKey(name: 'expectedTimeToComplete')
//   final String? expectedTimeToComplete;
//   final String? recurrence;
//   final String? id;
//   @JsonKey(name: 'actualTimeToComplete')
//   final String? actualTimeToComplete;
//   final DateTime? endTime;
//   final DateTime? startTime;
//   @JsonKey(name: 'assignedTime')
//   final DateTime? assignedTime;
//   @JsonKey(name: 'totalTimeSpent')
//   final String? totalTimeSpent;
//   @JsonKey(name: 'priority')
//   final TaskPriority? priority;
//   final String? name;

//   Task({
//     this.notes,
//     this.assignedDate,
//     this.expectedTimeToComplete,
//     this.recurrence,
//     this.id,
//     this.actualTimeToComplete,
//     this.endTime,
//     this.startTime,
//     this.assignedTime,
//     this.totalTimeSpent,
//     this.priority,
//     this.name,
//   });

//   factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
//   Map<String, dynamic> toJson() => _$TaskToJson(this);
// }