import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTimerWidget extends StatelessWidget {
  final int remainingTime;
  final double radius;
  final Color backgroundColor;
  final Color valueColor;

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

