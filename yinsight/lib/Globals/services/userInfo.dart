import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// A class to handle user information and related operations.
class UserInformation {
  // static const http_endpoint = 'http://192.168.0.217:8080';
  static const http_endpoint = 'https://yinsight-eabd41a7f368.herokuapp.com';
  // static const http_endpoint = 'http://172.27.37.82:8080';

  static final Map<String, String> routes = {
    'signup': '/signup',
    'reflect': '/reflect',

    'getFocusTasks': '/getAllTasksWithExpectedTimeToComplete',
    'deleteTaskOnFocus': '/deleteTask',
    'updateTotalTimeSpentForTask': '/updateTotalTimeSpentForTask',
    'getTotalTimeSpentForTask': '/getTotalTimeSpentForTask',
    //////////////////////////////////////////////

    'recallFileUpload': '/questions/uploadPDFs',
    'getPDFs': '/questions/getPDFs',
    'generateQuestions': '/questions/generate',
    'retreiveQuestions': '/questions/retreive',
    //////////////////////////////////////////////

    'updateISOCalendar': '/updateISOCalendar',
    'events': '/events',
    'getName': '/getName',
    'deletePDF': '/deletePDF',
    'getCreatedTasks': '/getAllTasks',

    'getAllEventsFromUploadedCalendar': '/getAllEventsFromUploadedCalendar',
    'addTaskToHomeCalendar': '/addTaskToHomeCalendar',
    'getDateFilteredTasksInHomeCalendar': '/getDateFilteredTasksInHomeCalendar',

    ////////////////////////////
    'getEvents': '/getAllTasks',
    // 'fetchEvents': '/fetchEvents',
    /////////////////////////////////

    'NumberOfTasksCreated': '/getNumberOfTasksCreated',
    'uploadProfilePicture': '/updateProfilePic',
    'getProfilePicture': '/getProfilePic',
    'createTask': '/createTask',

    ////////////////////////////
    'allocatePoints': '/allocatePoints',
    'checkForPoints': '/getPoints',
    'entireStreaks': '/getPointsForCalendar',
  };

  /// Gets the route for the given key.
  ///
  /// [key]: The key for the desired route.
  ///
  /// Returns the route as a string.
  static String getRoute(String key) {
    if (routes.containsKey(key)) {
      return http_endpoint + routes[key]!;
    } else {
      throw Exception('Route not found');
    }
  }

  /// Retrieves the user's profile picture from the server.
  ///
  /// Returns the URL of the profile picture if successful, otherwise an error message.
  static Future<String> getUserImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      String? token = await user?.getIdToken();

      if (token == null) throw Exception('No token found');

      var response = await http.get(
        Uri.parse(UserInformation.getRoute('getProfilePicture')),
        headers: {
          'Authorization': token,
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response(
              'Error', 408); // Request Timeout response status code
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        return data["profile_picture"];
      } else {
        // Handle errors or invalid status codes
        // print('Error fetching user data: ${response.body}');
        return "Error fetching user data";
      }
    } catch (e) {
      // print('Error getting user image: $e');
      return 'Error getting user image';
    }
  }

  /// Fetches the user data from the server.
  ///
  /// Returns the user data as a string if successful, otherwise an error message.
  Future<String> fetchUserData() async {
    // await Future.delayed(Duration(milliseconds: 250));

    try {
      final user = FirebaseAuth.instance.currentUser;
      String? token = await user?.getIdToken();

      // print("Token: $token");
      if (token == null) throw Exception('No token found');
      // print("Token: $token");
      var response = await http.get(
        Uri.parse(UserInformation.getRoute('getName')),
        headers: {
          'Authorization': token, // Include the token in the request header
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response(
              'Error', 408); // Request Timeout response status code
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String message =
            data["message"]; // Or however you're parsing the username
        return message; // Return the fetched username
      } else {
        // Handle errors or invalid status codes
        // print("Error fetching user data: ${response.body}");
        return "Error fetching user data"; // Return a default or error message
      }
    } catch (e) {
      // print(">>>>>>>>> Error fetching user data: $e");
      return "Error fetching user data"; // Return a default or error message in case of exception
    }
  }
}
