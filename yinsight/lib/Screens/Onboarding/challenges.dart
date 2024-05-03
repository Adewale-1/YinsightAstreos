// challenges_screen.dart
import 'package:flutter/material.dart';



class ChallengesScreen extends StatelessWidget {

  final VoidCallback onChallengeSelected;


  const ChallengesScreen({
    super.key,
    required this.onChallengeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'What do you struggle with?',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: onChallengeSelected,
            child: const Text('Negative Mindset',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onChallengeSelected,
            child: const Text(
              'Wavering Focus',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onChallengeSelected,
            child: const Text(
              'Time Management',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onChallengeSelected,
            child: const Text(
              'Information Overload',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),

        ],
      ),
    );
  }
}
