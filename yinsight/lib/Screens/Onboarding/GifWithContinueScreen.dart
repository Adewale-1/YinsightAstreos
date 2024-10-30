import 'package:flutter/material.dart';
import 'package:yinsight/navigationBar.dart';

import 'package:video_player/video_player.dart';

class GifWithContinueScreen extends StatefulWidget {
  const GifWithContinueScreen({super.key});
  static const String id = 'gif_with_continue_screen';

  @override
  _GifWithContinueScreenState createState() => _GifWithContinueScreenState();
}

class _GifWithContinueScreenState extends State<GifWithContinueScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the video player controller with the MP4 file
    _controller = VideoPlayerController.asset(
      'lib/Assets/Image_Comp/OnboardingImages/homepageWorkflow.mp4', // Path to your MP4 video
    )..initialize().then((_) {
        setState(
            () {}); // Ensure the first frame is shown after the video is initialized
        _controller.setLooping(true); // Loop the video if needed
        _controller.play(); // Auto-play the video
      });
  }

  @override
  void dispose() {
    // Clean up the video player controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 70.0, bottom: 20.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Some essential tips',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text: '\nTouch and hold to move task into calendar',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  // Replacing Image.asset with VideoPlayer widget
                  child: _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : Center(
                          child:
                              CircularProgressIndicator(), // Show loading indicator while the video initializes
                        ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    MainNavigationScreen.id,
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
