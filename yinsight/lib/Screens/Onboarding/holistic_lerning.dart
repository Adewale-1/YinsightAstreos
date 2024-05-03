// holistic_learning_screen.dart
import 'package:flutter/material.dart';

class HolisticLearningScreen extends StatelessWidget {
  const HolisticLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'lib/Assets/Image_Comp/OnboardingImages/potential.png',
            width: 500, // Specify your image width
            height:500, // Specify your image height
          ),
          const SizedBox(height: 20), 
          const Text('Using a holistic learning system, we take off all limitations that you can face when reaching for their goals.',
            style: TextStyle(
              color: Color.fromARGB(221, 0, 0, 0),
              fontSize: 16,
            ),
          ),
          // Add more widgets as needed
        ],
      ),
    );
  }
}
