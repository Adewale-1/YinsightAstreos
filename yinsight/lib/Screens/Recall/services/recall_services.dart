import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:yinsight/Globals/services/userInfo.dart';

/// A service class for handling recall-related operations.
class RecallServices {
  /// Generates questions based on the selected file names.
  ///
  /// [selectedFileNames]: A set of selected file names.
  ///
  /// Throws an [Exception] if no token is found.
  static Future<bool> generateQuestions(Set<String> selectedFiles) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      String? token = await user?.getIdToken();

      if (token == null) {
        print("No token found");
        return false;
      }

      final url = UserInformation.getRoute('generateQuestions');

      for (String filePath in selectedFiles) {
        final fileName = filePath.split('/').last;

        final Map<String, dynamic> requestBody = {
          'file_name': fileName,
        };

        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': token,
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        );

        if (response.statusCode != 200) {
          print(
              'Failed to generate questions for $fileName: ${response.statusCode}');
          print('Response body: ${response.body}');
          return false;
        }

        print('Successfully generated questions for $fileName');
      }

      print('All questions generated successfully');

      // Trigger the push notification after successful generation
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'basic_channel', // Same as the one defined in main.dart
          title: 'Questions Generated!',
          body: 'Your questions have been successfully generated.',
        ),
      );

      return true;
    } catch (e, stackTrace) {
      print('Error generating questions: $e');
      print('Stack trace: $stackTrace');
      // Trigger the push notification after successful generation
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'basic_channel', // Same as the one defined in main.dart
          title: 'Questions Generated!',
          body:
              'An error occurred while generating questions, please try again.',
        ),
      );
      return false;
    }
  }
}
