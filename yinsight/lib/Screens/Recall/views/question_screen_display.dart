
// class QuestionScreenDisplay extends StatefulWidget {
//   const QuestionScreenDisplay({super.key});

//   @override
//   _QuestionScreenDisplayState createState() => _QuestionScreenDisplayState();
// }

// class _QuestionScreenDisplayState extends State<QuestionScreenDisplay> {
//   int _remainingTime = 240; // 4 minutes in seconds
//   late Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         if (_remainingTime > 0) {
//           _remainingTime --;
//         } else {
//           _timer.cancel();
//           // Handle what happens when the timer finishes, if necessary
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }


//   @override
//   Widget build(BuildContext context) {
//     return  Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Text(
//                   'The question text will be displayed here.',
//                   style: GoogleFonts.lexend(
//                     textStyle: const TextStyle(
//                       color: Colors.black,
//                       fontSize: 12.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 60), // Adjust height as needed
        
//               const SizedBox(height: 200),
        
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           // Logic to show the answer
//                         },
//                         child: const Text('Show Answer'),
//                       ),
//                     ),
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           // Logic to fetch and display the next question
//                         },
//                         child: const Text('Next'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           // Positioned CustomTimerWidget at the top-left corner
//           Positioned(
//             top: 0,
//             left: 30,
//             child: CustomTimerWidget(
//               remainingTime: _remainingTime,
//               radius: 40.0,
//               backgroundColor: Colors.grey[300]!,
//               valueColor: Colors.blue,
//             ),
//           ),
//           ],
//         ),
//       )
//     );
//   }
// }

