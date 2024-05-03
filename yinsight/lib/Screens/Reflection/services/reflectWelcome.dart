// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class WelcomeService {
//   final BuildContext context;

//   WelcomeService(this.context);
// Future<void> checkFirstTimeAndShowDialog() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool? isLastTime = prefs.getBool('isLastTime');

//     // Log the current state of isLastTime
//     print("Current state of isLastTime>>>>>>>>>>>>>>>>>>>>>>>>: $isLastTime");

//     if (isLastTime == null || isLastTime) { // Adjusted condition to check for null
//       await showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text("Lets Chill!😀"),
//           content: Text(
//             "🌟 Welcome to the Reflect Section! 🌟\n\nThis is your personal space to unwind and delve into self-reflection. 🧘 Swipe up on any section to get started.\n\nAs you answer the questions, be as honest as you can — it's just between you and yourself; even Yinsight won't peek! 🤫 Let's explore and grow together! 🌱",
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text("Got It!"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         ),
//       );

//       await prefs.setBool('isLastTime', false);
//       print("Dialog shown and isLastTime set to false>>>>>>>>>>>>>>>>>>>>>>>>");
//     } else {
//       print("Dialog not shown, isLastTime is false>>>>>>>>>>>>>>>>>>>>>>");
//     }
//   }
// }



