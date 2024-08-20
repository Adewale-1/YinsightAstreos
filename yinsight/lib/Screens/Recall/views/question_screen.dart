

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yinsight/Globals/services/userInfo.dart';

/// A screen that displays a list of questions retrieved from a server.
class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});
  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  List<Map<String, dynamic>> questions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
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
          questions = List<Map<String, dynamic>>.from(data['questions'].map((q) => {'question': q['question_text'], 'answer': q['answer']}));
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
              ? const Center(child: Text('No questions available.', style: TextStyle(fontSize: 20, color: Colors.black)))
              : ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  // String? selectedAnswer; 
                  return Container(
                    width: double.infinity,  // Ensures the container takes up the full width available
                    padding: const EdgeInsets.all(10),  // Padding around each question item for better spacing
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,  // Aligns the text to the start of the column
                      children: [
                        Text('Question ${index + 1}\n${questions[index]['question']}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black),  // Styling the question text
                          softWrap: true,  // Allows text wrapping if the content exceeds the line width
                        ),
                        ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),  // Padding inside the ExpansionTile
                          title: const Text('Show Answer', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8),  // Padding for the answer container
                              color: Colors.grey[200],  // Background color for the answer section
                              child: Text('Answer\n${questions[index]['answer']}',
                                style: const TextStyle(fontSize: 14,color: Colors.black),  // Answer text styling
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}

