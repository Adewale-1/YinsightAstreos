import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReflectionCard extends StatelessWidget {
  final double cardHeight;
  final double cardWidth;
  final VoidCallback onTap;

  const ReflectionCard({
    super.key,
    required this.cardHeight,
    required this.cardWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        height: cardHeight,
        width: cardWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          border: Border.all(width: 1, color: const Color(0xFFAD00FF)),
        ),
        // Your reflection card content here
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10), // Space from the top of the card
                Text(
                  'REFLECT',
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10), // Space between "REFLECT" text and smaller cards
                // This Container will hold the smaller cards
                SizedBox(
                  height: 50,
                  // color: Colors.amberAccent, // Adjust the height according to your needs
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (index) => _buildSmallCard(screenHeight * 0.08, screenWidth *0.06)), // Using small cards
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 35, // Position from the bottom of the larger card
              child: Text(
                'CHOOSE A CARD',
                style: GoogleFonts.lexend(
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  }

  Widget _buildSmallCard(double height, double width) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF1D6FF),
        border: Border.all(color: Colors.black),
      ),
    );
  }
}
