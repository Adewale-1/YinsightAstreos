// onboarding_controller.dart
import 'package:flutter/material.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yinsight/Screens/Login_Signup/widgets/SignUpScreen.dart';
import 'package:yinsight/Screens/Onboarding/challenges.dart';
import 'package:yinsight/Screens/Onboarding/feedback.dart';
import 'package:yinsight/Screens/Onboarding/holistic_lerning.dart';
import 'package:yinsight/Screens/Onboarding/welcome_screen.dart';


class OnboardingController extends StatefulWidget {
  const OnboardingController({super.key});
  static const String id = 'Onboarding_Controller';

  @override
  _OnboardingControllerState createState() => _OnboardingControllerState();
}

class _OnboardingControllerState extends State<OnboardingController> {
  final PageController _pageController = PageController(initialPage: 0);
  late List<Widget> _pages;
  int _currentPage = 0;

  @override
  void initState() {
      super.initState();
      _pages = [
        const WelcomeScreen(),
        const HolisticLearningScreen(),
        ChallengesScreen(
          onChallengeSelected: () => navigateToFeedbackScreen(true),
        ),
        const SignUpScreen(), 
      ];
  }
  void navigateToFeedbackScreen(bool challengeSelected) {
    Widget feedbackScreen = challengeSelected
      ? FeedbackScreen(
          message: "Don’t worry\nWe are here to help.\nLet’s get you started.",
          onSignUpPressed: () => _pageController.jumpToPage(_pages.length - 1),
        )
      : FeedbackScreen(
          message: "That is totally fine\nWe've got you covered",
          onSignUpPressed: () => _pageController.jumpToPage(_pages.length - 1),
        );

    setState(() {
      _pages.insert(_pages.length - 1, feedbackScreen);
      _currentPage += 1;
    });

    _pageController.jumpToPage(_currentPage);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        onPageChanged: (int page) {
          if (page < _currentPage) { // Prevent swiping back
            _pageController.jumpToPage(_currentPage);
          } else {
            setState(() {
              _currentPage = page;
            });
          }
        },
        physics: const NeverScrollableScrollPhysics(), // Disable swiping
        children: _pages,
      ),
      bottomSheet:  (_currentPage != _pages.length - 1 && _currentPage != 2 && _currentPage != _pages.length - 2) 
          ? Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SmoothPageIndicator(
                    controller: _pageController, // Connect the controller
                    count: _pages.length - 1, // Exclude SignUpScreen from count
                    effect: const SlideEffect( // Customizable effect
                      activeDotColor: Colors.deepPurple, // Example active dot color
                      dotHeight: 10,
                      dotWidth: 10,
                      spacing: 8.0,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          _pageController.jumpToPage(_pages.length - 1);
                        },
                        child: const Text('SKIP'),
                      ),
                      TextButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('NEXT'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

 
}

