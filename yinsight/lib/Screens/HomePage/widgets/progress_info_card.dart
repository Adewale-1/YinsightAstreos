import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressInfoCard extends StatelessWidget {
  final String title;
  final double progress;
  final Color color;
  final VoidCallback onTap;

  const ProgressInfoCard({
    super.key, 
    required this.title,
    required this.progress,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            LinearProgressIndicator(
              value: progress,
              color: color,
              backgroundColor: color.withOpacity(0.2),
              minHeight: 20, // Make the progress bar thicker
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }
}