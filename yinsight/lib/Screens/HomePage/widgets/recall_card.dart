import 'package:flutter/material.dart';

/// A card widget for recall functionality.
class RecallCard extends StatelessWidget {
  final double height;
  final VoidCallback onTap;

  /// Creates a [RecallCard] instance.
  ///
  /// [height]: The height of the card.
  /// [onTap]: The callback function to be called when the card is tapped.
  const RecallCard({super.key, required this.height, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return  Container(
        height: height,
        width: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color(0xFFFFD6F1),
          border: Border.all(width: 1, color: const Color(0xFFFF00A8)),
        ),
        // Your recall card content here
        child: const Stack(
              children: [ 
                Positioned(
                  left: 16,
                  top: 16,
                  child: Text('6',
                    style: TextStyle(
                      color: Color(0xFF1C1C1E),
                      fontSize: 32,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w600,
                      height: 0,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 49,
                  child: Text('Overdue',
                    style: TextStyle(
                      color: Color(0xFF1C1C1E),
                      fontSize: 22,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w600,
                      height: 0,
                    ),
                  ),
                ),
                Positioned(
                  left: 53,
                  top: 30, 
                  child: Text('Questions',
                    style: TextStyle(
                      color: Color(0xFF1C1C1E),
                      fontSize: 13,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w600,
                      height: 0,
                    ),
                  ),
                ),
              ],
            )
            
      );
  }
}
