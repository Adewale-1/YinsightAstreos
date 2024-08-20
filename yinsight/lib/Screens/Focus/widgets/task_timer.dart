
import 'package:flutter/material.dart';

class TaskTimer extends StatelessWidget {
  final String task;
  final String actualTime;
  final String expectedTime;
  final bool isRunning;
  final bool isChecked; // New property to handle checkbox state
  final VoidCallback onStart;
  final VoidCallback onPause;
  final ValueChanged<bool?> onCheckboxChanged; // New callback for checkbox change

  const TaskTimer({
    super.key,
    required this.task,
    required this.actualTime,
    required this.expectedTime,
    required this.isRunning,
    required this.isChecked, // Initialize isChecked
    required this.onStart,
    required this.onPause,
    required this.onCheckboxChanged, // Initialize onCheckboxChanged callback
  });

  /// Creates a container widget for a task.
  ///
  /// [context]: The build context.
  /// [task]: The name of the task.
  /// [time]: The elapsed time for the task.
  ///
  /// Returns the task container widget.
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _taskAndTimeRow(task, actualTime, onCheckboxChanged, isChecked),
          _statusIndicator(),
          _actionAndTimeDetailsRow(isRunning, onStart, onPause),
        ],
      ),
    );
  }

  /// Creates a row widget for the task name and elapsed time.
  ///
  /// [task]: The name of the task.
  /// [time]: The elapsed time for the task.
  /// [onCheckboxChanged]: Callback triggered when the checkbox state changes.
  /// [isChecked]: State of the checkbox.
  ///
  /// Returns the task and time row widget.
  Widget _taskAndTimeRow(String task, String time, ValueChanged<bool?> onCheckboxChanged, bool isChecked) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Checkbox(
                value: isChecked,
                onChanged: (bool? value) {
                  onCheckboxChanged(value);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              Expanded(
                child: Text(
                  task,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }


  /// Creates a widget for the status indicator.
  ///
  /// Returns the status indicator widget.
  Widget _statusIndicator() {
    return Row(
      children: [
        const SizedBox(width: 50),
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(right: 8.0),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green, // Example color
          ),
        ),
      ],
    );
  }

  /// Creates a row widget for the action buttons and time details.
  ///
  /// [task]: The name of the task.
  ///
  /// Returns the action and time details row widget.
  Widget _actionAndTimeDetailsRow(bool isRunning, VoidCallback onStart, VoidCallback onPause) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            isRunning ? Icons.pause : Icons.play_arrow,
            size: 40,
            color: Colors.grey[400],
          ),
          onPressed: isRunning ? onPause : onStart,
        ),
        Row(
          children: [
            _timeDetailsColumn('Actual', actualTime),
            const SizedBox(width: 10),
            _timeDetailsColumn('Expected', expectedTime),
          ],
        ),
      ],
    );
  }

  /// Creates a column widget for time details.
  ///
  /// [title]: The title of the time detail.
  /// [time]: The time string.
  ///
  /// Returns the time details column widget.
  Widget _timeDetailsColumn(String title, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
