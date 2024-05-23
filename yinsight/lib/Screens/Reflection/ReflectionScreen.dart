import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import 'package:http/http.dart' as http;
import 'package:yinsight/Globals/services/userInfo.dart';
import 'dart:convert';

import 'package:yinsight/navigationBar.dart';

/// The screen for reflecting on questions related to a specific category.
class ReflectionScreen extends StatefulWidget {
  final String heroTag;
  final Color backgroundColor;
  final String categoryName; // To get the selected category name from the CardScreen

  const ReflectionScreen(
      {super.key,
      required this.heroTag,
      required this.backgroundColor,
      required this.categoryName});

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  bool isLikedButtonClicked = false;

  bool isVisible = true;
  String? question;

  @override
  void initState() {
    super.initState();
    fetchQuestion();
  }

  /// Fetches a reflection question for the specified category from the server.
  void fetchQuestion() async {
 
    var url = Uri.parse(UserInformation.getRoute('reflect'));
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'category': widget.categoryName}),
      );
      // print('The card selected -> ${widget.categoryName}');
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          question = data['question_generated'];
        });
      } else {
        throw Exception('Failed to load question: ${response.body}');
      }
    } catch (e) {
      // print('An error occurred while fetching question: $e');
    }
  }

  /// Shows a material banner with a success message and then navigates back to the card screen.
  void showMaterialBanner(BuildContext context, String title, String message) {
    final materialBanner = MaterialBanner(
      elevation: 0,
      backgroundColor: Colors.transparent,
      forceActionsBelow: true,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: ContentType.success,
        inMaterialBanner: true,
      ),
      actions: const [SizedBox.shrink()],
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(materialBanner);

    Future.delayed(
      const Duration(milliseconds: 2000),
      () {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        Future.delayed(
          const Duration(milliseconds: 500),
          _backToCardScreen
        );
      },
    );
  }


  /// Creates the like button widget with its functionality.
  Visibility likeButtonFuntions() {
    return Visibility(
      visible: isVisible,
      child: Container(
        color: Colors.black,
        child: Container(
          height: 60,
          width: 60,
          color: widget.backgroundColor,
          child: IconButton(
            icon: Icon(
              isLikedButtonClicked ? Icons.favorite : Icons.favorite_border,
              color: isLikedButtonClicked ? Colors.red : Colors.white,
              size: 55,
            ),
            onPressed: () {
              setState(
                () {
                  isLikedButtonClicked = !isLikedButtonClicked;
                },
              );

              Future.delayed(
                const Duration(milliseconds: 1500),
                () {
                  setState(
                    () {
                      isVisible = false;
                    },
                  );
                  showMaterialBanner(context, 'Oh Hey!!',
                      'Successfully saved');
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// Creates a floating action button to navigate back to the card screen.
  Widget buildFloatingActionButton(double iconSize) {
    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.all(8.0), // You can adjust the padding as needed
        child: FloatingActionButton(
          onPressed: _backToCardScreen,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.chevron_left,
            size: iconSize,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  /// Aligns and styles a text widget within the reflection screen.
  Align alignWidgetQuestion(
      double xAxis, double yAxis, int height, String text, FontWeight weight) {
    return Align(
      alignment: Alignment(xAxis, yAxis),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 60,
          width: 450,
          color: Colors.white,
          child: Text(
            text,
            style: GoogleFonts.lexend(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: weight,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }


  /// Aligns and styles a dynamic text widget for displaying the fetched question.
  Widget alignWidgetDynamicQuestion(
      double xAxis, double yAxis, int height, FontWeight weight) {
    // Check if question is not loaded yet
    if (question == null) {
      return Align(
        alignment: Alignment(xAxis, yAxis),
        child: const Padding(
          padding: EdgeInsets.all(10.0),
          child: SizedBox(
            height: 60,
            width: 60,
            child: CircularProgressIndicator(), // Show loading indicator
          ),
        ),
      );
    } else {
      // If question is loaded, show it
      return Align(
        alignment: Alignment(xAxis, yAxis),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 60,
            width: 450,
            color: Colors.white,
            child: Text(
              question!, // Use the loaded question here
              style: GoogleFonts.lexend(
                textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: weight,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
  }


  /// Navigates back to the card screen.
  void _backToCardScreen() {
    Navigator.pushNamedAndRemoveUntil(context, MainNavigationScreen.id, (Route<dynamic> route) => false);
  }


  /// Builds a fade-in widget for the reflection text area and save button.
  Widget fadeUpWidget() {
    return FadeInUp(
      duration: const Duration(milliseconds: 900),
      delay: const Duration(milliseconds: 250),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 430,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            color: Colors.black, // Color of Fade Up container
          ),
          child: Container(
            height: 430,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              color: widget.backgroundColor, // Color of Fade Up container
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      likeButtonFuntions(),
                      Visibility(
                        visible: isVisible,
                        child: Container(
                          height: 60,
                          color: Colors.black,
                          child: Container(
                            height: 60,
                            // width: 60,
                            color: widget
                                .backgroundColor, // Color of Fade Up container
                            child: Text(
                              'Save',
                              style: GoogleFonts.lexend(
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Write a note',
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      maxLength: 1000,
                      maxLines: null,
                      autocorrect: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Hero(
            tag: widget.heroTag,
            child: Material(
              type: MaterialType.canvas,
              child: Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    alignWidgetQuestion(0.0, -0.8, 30,
                        'Hey, Lets\'s dive deeper', FontWeight.normal),
                    alignWidgetQuestion(0.0, -0.55, 50, 'Question for today:',
                        FontWeight.normal),
                    alignWidgetDynamicQuestion(0.0, -0.43, 60, FontWeight.bold),
                    fadeUpWidget(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  onPressed: _backToCardScreen,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.chevron_left,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}