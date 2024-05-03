import 'package:flutter/material.dart';
// Import flutter_svg

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'lib/Assets/Image_Comp/OnboardingImages/girlStudying.png',
            width: 500, // Specify your image width
            height: 500, // Specify your image height
          ),
          const SizedBox(height: 20), // Add some space between the image and the text
          const Text('Welcome to Yinsight, a revolution in learning, where achieving your potential has never been so easy.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          // Add more widgets as needed
        ],
      ),
    );
  }
}
