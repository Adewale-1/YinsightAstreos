import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A custom timer widget that displays a countdown timer with a circular progress indicator.
class CustomTimerWidget extends StatelessWidget {
  /// The remaining time in seconds.
  final int remainingTime;

  /// The radius of the circular progress indicator.
  final double radius;
  /// The background color of the circular progress indicator.
  final Color backgroundColor;

  /// The color of the progress value in the circular progress indicator.
  final Color valueColor;

  /// Creates a [CustomTimerWidget] with the specified properties.
  ///
  /// [remainingTime]: The remaining time in seconds.
  /// [radius]: The radius of the circular progress indicator. Defaults to 110.0.
  /// [backgroundColor]: The background color of the circular progress indicator. Defaults to [Colors.grey].
  /// [valueColor]: The color of the progress value in the circular progress indicator. Defaults to [Colors.blue].
  const CustomTimerWidget({super.key, 
    required this.remainingTime,
    this.radius = 110.0,
    this.backgroundColor = Colors.grey,
    this.valueColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: CircularProgressIndicator(
              value: remainingTime / 240,
              backgroundColor: backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(valueColor),
              strokeWidth: 8,
            ),
          ),
          Text('${remainingTime ~/ 60}:${(remainingTime % 60).toString().padLeft(2, '0')}',
          style: GoogleFonts.lexend(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

