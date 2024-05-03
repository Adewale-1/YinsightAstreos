import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yinsight/Globals/services/userInfo.dart';


class RecallServices{


    static Future<void> generateQuestions(Set<String> selectedFileNames) async {
      if (selectedFileNames.isEmpty) {
        // print("No files selected.");
        return;
      }

      var uri = Uri.parse(UserInformation.getRoute('generateQuestions')); 
      final user = FirebaseAuth.instance.currentUser;
      String? token = await user?.getIdToken();

      if (token == null) {
        throw Exception('No token found');
      }

      var fileNamesList = selectedFileNames.toList();

      var request = http.Request('POST', uri)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': token,
        })
        ..body = jsonEncode({
          'file_name': fileNamesList.first,  // Send the first file name
        });
      try {
        var response = await request.send();
        // print("Response>>>>>>>>>>>>>>: $response");
        // print("Response status code: ${response.statusCode}");
        if (response.statusCode == 200) {
        // Questions generated successfully, show a dialog alert.
          // showDialog(
            // context: context, 
            // builder: (BuildContext context){
            //   return AlertDialog(
            //     title: Text("Success"),
            //     content: Text("Your questions are ready"),
            //     actions: <Widget>[
            //       TextButton(
            //         onPressed: () {
            //           Navigator.of(context).pop();
            //         },
            //         child: Text('OK'),
            //       ),
            //     ],
            //   );
            // }

          // );

          // print("Questions generated successfully.")
          AwesomeNotifications().createNotification(
                      content: NotificationContent(
                        id: 1,
                        channelKey: 'basic_channel',
                        title: 'Question Generation',
                        body: 'Hey👋,Your questions have been generated successfully!',
                      ),
                    );
        } else {
          // print('Failed to generate questions. Server responded with status code: ${response.statusCode}');
          var responseBody = await response.stream.bytesToString();
          // print('Response body: $responseBody');
        }
      } catch (e) {
        // print('Error sending generation request: $e');
      }
    }
  }
    

