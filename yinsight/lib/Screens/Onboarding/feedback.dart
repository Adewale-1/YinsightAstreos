import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  final String message;
  final VoidCallback onSignUpPressed;

  const FeedbackScreen({
    super.key,
    required this.message,
    required this.onSignUpPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Splitting the message into lines for individual styling
    List<String> messageLines = message.split('\n');
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Using RichText for more detailed styling
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: messageLines.map((line) => TextSpan(
                  text: "$line\n\n", // Add two line breaks for more space
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                )).toList(),
              style: DefaultTextStyle.of(context).style,
            ),
          ),
          const SizedBox(height: 20), // Adjust space above the button as needed
          ElevatedButton(
            onPressed: onSignUpPressed,
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}
