import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:http/http.dart' as http;
import 'package:yinsight/Globals/services/userInfo.dart';

/// A screen that displays a list of questions retrieved from a server.
class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});
  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<Map<String, dynamic>> questions = [];
  late CardSwiperController controller;

  bool isLoading = true;
  String activity3 = "showQuestion";
  @override
  void initState() {
    super.initState();
    fetchQuestions();
    _setupAnimation();
    controller = CardSwiperController();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkAndUpdatePoints());
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  Future<void> _checkAndUpdatePoints() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      String? token = await user?.getIdToken();
      if (token == null) {
        print("No token found");
        return;
      }

      final url =
          '${UserInformation.getRoute('checkForPoints')}/?activity=$activity3';
      // print('Attempting to call URL: $url');
      // print('Token: $token'); // Print token for debugging

      final httpClient = HttpClient();
      try {
        final request = await httpClient.getUrl(Uri.parse(url));
        request.headers.set('Authorization', token);
        // print('Request headers: ${request.headers}'); // Print request headers

        final response = await request.close();
        // print("Response Status: ${response.statusCode}");

        final responseBody = await response.transform(utf8.decoder).join();
        // print("Response Body: $responseBody");

        if (response.statusCode == 200) {
          final data = json.decode(responseBody);
          final pointsEarned = data['points_earned'];
          final lastOpenedDateTime = data['dateOfLastActivity'];

          if (lastOpenedDateTime != null) {
            final lastOpenedDate = DateTime.parse(lastOpenedDateTime).toLocal();
            final currentDate = DateTime.now().toLocal();
            print("Points earned is : $pointsEarned");
            print("Current date is $currentDate");
            print(
                "Difference is : ${currentDate.difference(lastOpenedDate).inDays}");
            if (currentDate.difference(lastOpenedDate).inDays == 0 &&
                pointsEarned == 1.5) {
              print('Points already allocated today, not showing animation');
              return;
            }
          }

          print('Updating daily activity and showing animation');
          await _updateDailyActivityAndStreak();
          _showTransitionGif();
        } else {
          print('Failed to check points: ${response.statusCode}');
          print('Response body: $responseBody');
        }
      } finally {
        httpClient.close();
      }
    } catch (e, stackTrace) {
      print('Error checking points: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _updateDailyActivityAndStreak() async {
    final user = FirebaseAuth.instance.currentUser;
    String? token = await user?.getIdToken();

    if (token == null) {
      throw Exception('No token found');
    }

    final httpClient = HttpClient();
    try {
      final request = await httpClient
          .postUrl(Uri.parse(UserInformation.getRoute('allocatePoints')));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, token);
      request.add(utf8.encode(json.encode({'activity': activity3})));

      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Failed to update daily activity and streak');
      }
    } finally {
      httpClient.close();
    }
  }

  void _showTransitionGif() {
    _overlayEntry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5 * _animation.value),
              child: Center(
                child: Image.asset(
                  'lib/Assets/Image_Comp/Icons/singleCoin.gif',
                  width: 100 + (50 * _animation.value),
                  height: 100 + (50 * _animation.value),
                ),
              ),
            ),
          );
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _animationController.reverse().then((_) {
          _overlayEntry?.remove();
          _overlayEntry = null;
        });
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  /// Fetches questions from the server.
  ///
  /// This method sends an HTTP GET request to the server to retrieve a list of questions.
  /// The retrieved questions are stored in the [questions] list and the loading state is updated.
  Future<void> fetchQuestions() async {
    var uri = Uri.parse(UserInformation.getRoute('retreiveQuestions'));
    try {
      final user = FirebaseAuth.instance.currentUser;
      String? token = await user?.getIdToken();

      if (token == null) throw Exception('No token found');
      var response = await http.get(uri, headers: {
        'Authorization': token,
      });
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          questions = List<Map<String, dynamic>>.from(data['questions'].map(
              (q) => {'question': q['question_text'], 'answer': q['answer']}));
          // questions.forEach((_) => answerVisibility[questions.indexOf(_)] = false);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load questions: ${response.body}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      // print('Error fetching questions: $e');
    }
  }

  // Widget _buildQuestionCard(Map<String, dynamic> question, int index) {
  //   return Center(
  //     child: Container(
  //       margin: const EdgeInsets.all(8.0),
  //       decoration: BoxDecoration(
  //         color: Colors.grey[200],
  //         borderRadius: BorderRadius.circular(8.0),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.grey.withOpacity(0.5),
  //             spreadRadius: 2,
  //             blurRadius: 4,
  //             offset: const Offset(0, 3),
  //           ),
  //         ],
  //       ),
  //       height: 450,
  //       width: 350,
  //       child: SingleChildScrollView(
  //         child: Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Question ${index + 1}',
  //                 style: const TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.blue,
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 question['question'],
  //                 style: const TextStyle(
  //                   fontSize: 16,
  //                   color: Colors.black,
  //                   fontFamily: 'NotoSansMath',
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               ExpansionTile(
  //                 key: Key('expansionTile_$index'), // Add this line
  //                 title: const Text(
  //                   'Show Answer',
  //                   style: TextStyle(
  //                     color: Colors.blue,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 children: [
  //                   Padding(
  //                     padding: const EdgeInsets.all(8),
  //                     child: Text(
  //                       question['answer'],
  //                       style: const TextStyle(
  //                         fontSize: 14,
  //                         color: Colors.black,
  //                         fontFamily: 'NotoSansMath',
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildQuestionCard(Map<String, dynamic> question, int index) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        height: 450,
        width: 350,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                TeXView(
                  child: TeXViewDocument(
                    question[
                        'question'], // Ensure question text is in LaTeX format if needed
                    style: TeXViewStyle(
                      contentColor: Colors.black,
                      fontStyle: TeXViewFontStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ExpansionTile(
                  key: Key('expansionTile_$index'),
                  title: const Text(
                    'Show Answer',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TeXView(
                        child: TeXViewDocument(
                          question[
                              'answer'], // Ensure answer text is in LaTeX format if needed
                          style: TeXViewStyle(
                            contentColor: Colors.black,
                            fontStyle: TeXViewFontStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Questions', style: TextStyle(color: Colors.black)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : questions.isEmpty
              ? const Center(
                  child: Text(
                    'No questions available.',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                )
              : CardSwiper(
                  controller: controller,
                  cardsCount: questions.length,
                  cardBuilder: (context, index, _, __) =>
                      _buildQuestionCard(questions[index], index),
                ),
    );
  }
}
