import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yinsight/Globals/services/userInfo.dart';
import 'package:yinsight/Screens/Reflection/ReflectionScreen.dart';
import 'package:yinsight/Screens/Reflection/SwipeUpAnimation.dart';
import 'package:yinsight/navigationBar.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});
  static const String id = 'CardScreen';

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> with TickerProviderStateMixin {
  late final PageController _pageController;
   final bool _isDialogShown = false;
  late final List<AnimationController> _cardAnimationControllers;
  late final List<Animation<double>> _cardOffsetAnimations;
  final UserInformation userInformation = UserInformation();

  // int currentPage = 0;



  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Self-Care',
      'picture': 'lib/Assets/Image_Comp/CardImages/SelfCare1.png',
      'color': const Color.fromARGB(190, 128, 205, 29),
    },
    {
      'name': 'Growth',
      'picture': 'lib/Assets/Image_Comp/CardImages/GrowthBG.png',
      'color': const Color.fromARGB(106, 168, 79, 5),
    },
    {
      'name': 'Finances',
      'picture': 'lib/Assets/Image_Comp/CardImages/FinanceBG.png',
      'color': const Color.fromARGB(33, 150, 243, 5),
    },
    {
      'name': 'Relationships',
      'picture': 'lib/Assets/Image_Comp/CardImages/RelationshipBG.png',
      'color': const Color.fromARGB(255, 107, 47, 171),
    },
    {
      'name': 'Future',
      'picture': 'lib/Assets/Image_Comp/CardImages/FutureBG.png',
      'color': const Color.fromARGB(224, 122, 95, 5),
    },
    {
      'name': 'Values',
      'picture': 'lib/Assets/Image_Comp/CardImages/brutus.png',
      'color': const Color.fromARGB(0, 128, 128, 5),
    },
    {
      'name': 'Community',
      'picture': 'lib/Assets/Image_Comp/CardImages/CommunityBG.png',
      'color': const Color.fromRGBO(42, 82, 190, 100),
    },

    // ... (add the rest of the entries with names, pictures, and colors)
  ];

  void _backToHomeScreen() {
    Navigator.pushNamedAndRemoveUntil(context, MainNavigationScreen.id, (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();
     _checkAndShowWelcomeDialog();
    _pageController = PageController(viewportFraction: 0.9);

    _cardAnimationControllers = categories
        .map(
          (_) => AnimationController(
            vsync: this,
            duration: const Duration(seconds: 2),
          ),
        )
        .toList();

    _cardOffsetAnimations = _cardAnimationControllers
        .map(
          (controller) => Tween(begin: 0.0, end: -20.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (_cardAnimationControllers.isNotEmpty) {
        _cardAnimationControllers[0]
            .repeat(reverse: true); // Start first card animation
      }
    });

  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _cardAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _checkAndShowWelcomeDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFourthShown = prefs.getBool('isFourthShown') ?? false;

    if (!isFourthShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog();
      });
      await prefs.setBool('isFourthShown', true);
    }
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Lets Chill !😀"),
          content: const Text(
            "🌟 Welcome to the Reflect Section! 🌟\n\nThis is your personal space to unwind and delve into self-reflection. 🧘 Swipe up on any section to get started.\n\nAs you answer the questions, be as honest as you can — it's just between you and yourself; even Yinsight won't peek! 🤫 Let's explore and grow together! 🌱",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Got It!"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
/// Update the Private method _navigateToReflectionScreen to also 
/// get which Card was selected so route the approipraite question 
/// to the ReflectionScreen
  void _navigateToReflectionScreen(String heroTag, Color color, String categoryName) {
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) => ReflectionScreen(
        heroTag: heroTag,
        backgroundColor: color,
        categoryName: categoryName,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ));
  }

  void onVerticalDragUpdate(DragUpdateDetails details, int index, Color color) {
    if (details.primaryDelta != null && details.primaryDelta! < -7) {
      // More sensitive drag detection
      final String heroTag = 'cardHeroTag$index';
      String categoryName = categories[index]['name']; // Get the category name
      _navigateToReflectionScreen(heroTag, color,categoryName);
    }
  }

  Widget _buildCard(BuildContext context, int index) {
    final category = categories[index];
    final String heroTag = 'cardHeroTag$index';

    return GestureDetector(
      onVerticalDragUpdate: (details) =>
          onVerticalDragUpdate(details, index, category['color']),
      child: Hero(
        tag: heroTag,
        child: AnimatedBuilder(
          animation: _cardOffsetAnimations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _cardOffsetAnimations[index].value),
              child: Card(
                color: category['color'],
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category['name'],
                        style: GoogleFonts.lexend(
                          textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: CircleAvatar(
                          radius: 450,
                          backgroundColor: category['color'],
                          backgroundImage: AssetImage(category['picture']),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SwipeUpIndicator(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }




  // ...









  
  @override
  Widget build(BuildContext context) {
    // WelcomeService(context).checkFirstTimeAndShowDialog();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Add home button and username display here
              SizedBox(
                // Text to navigate to the homescreen
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _backToHomeScreen();
                        });
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.chevron_left,
                        size: 40,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Column(
                children: [
                  FutureBuilder<String>(
                      future: userInformation.fetchUserData(),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          // Display a loading indicator while waiting for the data
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          // Handle any errors that might occur
                          return Text('Error: ${snapshot.error}');
                        } else {
                          // Once the data is fetched, display it
                          return Text(
                            snapshot.data ?? 'Username not found', // Handle the case where data might be null
                            style: GoogleFonts.lexend(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  Text(
                    "Let's take a step back",
                    style: GoogleFonts.lexend(
                      textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Text(
                    "REFLECT",
                    style: GoogleFonts.lexend(
                      textStyle: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  Text(
                    "Pick a category",
                    style: GoogleFonts.lexend(
                      textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return _buildCard(context, index);
                  },
                  onPageChanged: (int index) {
                    setState(() {
                      // Stop all animations
                      for (var controller in _cardAnimationControllers) {
                        controller.stop();
                      }
                      // Only start the animation if the controller is not currently animating
                      if (!_cardAnimationControllers[index].isAnimating) {
                        _cardAnimationControllers[index].repeat(reverse: true);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SmoothPageIndicator(
                controller: _pageController,
                count: categories.length,
                effect: const SlideEffect(
                  radius: 16,
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),
              // Navigation arrows
              // _buildPageNavigationButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageNavigationButtons(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
            icon: const Icon(Icons.chevron_left),
            color: Colors.black,
            iconSize: 20,
          ),
          IconButton(
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
            icon: const Icon(Icons.chevron_right),
            color: Colors.black,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}