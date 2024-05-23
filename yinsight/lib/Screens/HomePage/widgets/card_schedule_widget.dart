import 'package:flutter/material.dart';
import 'Calender/homeScreenCalender.dart'; 
import 'TaskNotes/task_section.dart'; 

/// A widget that combines a calendar and task section.
class CardScheduleWidget extends StatelessWidget {
  final double height;

  /// Creates a [CardScheduleWidget] instance.
  ///
  /// [height]: The height of the widget.
  const CardScheduleWidget({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          border: Border.all(width: 1, color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: const Row(
        children: [
          CalendarSection(),
          TaskSection(),
        ],
      ),
    );
  }

}


