import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yinsight/Screens/Login_Signup/services/user_Authentication.dart';

/// A screen for displaying the Google Calendar.
class CalendarDisplayScreen extends StatefulWidget {
  const CalendarDisplayScreen({super.key});

  @override
  _CalendarDisplayScreenState createState() => _CalendarDisplayScreenState();
}

class _CalendarDisplayScreenState extends State<CalendarDisplayScreen> {
  late final AuthServices _authServices;

  @override
  void initState() {
    super.initState();
    _authServices = AuthServices(context); // Initialize AuthServices instance
  }

  /// Picks a file and uploads it to the backend.
  ///
  /// [context]: The build context.
  // Future<void> pickAndUploadFile(BuildContext context) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   String? token = await user?.getIdToken();
  //   if (token == null) throw Exception('No token found');

  //   FilePickerResult? result = await FilePicker.platform.pickFiles();
  //   if (result != null) {
  //     Uri uri = Uri.parse(UserInformation.getRoute('updateISOCalendar'));
  //     var request = http.MultipartRequest('POST', uri)
  //       ..files.add(await http.MultipartFile.fromPath('file', result.files.single.path!))
  //       ..headers.addAll({
  //         "Authorization": token,
  //       });

  //     var response = await request.send();
  //     if (response.statusCode == 200) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Calendar imported successfully! Processing events...')),
  //       );
  //       Navigator.of(context).push(
  //         MaterialPageRoute(builder: (context) => const GoogleCalendarClass()),
  //       );
  //     } else {
  //       var responseBody = await response.stream.bytesToString();
  //       // print('Error response: $responseBody');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Failed to import calendar.')),
  //       );
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('File selection cancelled')),
  //     );
  //   }
  // }

  Widget squareTile() {
    return GestureDetector(
      onTap: () async {
        await _authServices.signInWithGoogle();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: SvgPicture.asset(
          "lib/Assets/Image_Comp/Icons/google.svg",
          width: 24, // Set your desired icon width
          height: 24, // Set your desired icon height
        ),
      ),
    );
  }

  Widget frame() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          children: [
            const Text(
              "Authenticate with",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Center(child: squareTile()),
          ],
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
        title: const Text(
          "Google Calendar Sync",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Center(child: frame()),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     appBar: AppBar(
  //       backgroundColor: Colors.white,
  //       foregroundColor: Colors.black,
  //       title: const Text("Google Calendar Sync",
  //         style: TextStyle(
  //           color: Colors.black,
  //         ),
  //       ),
  //     ),
  //     body: Center(
  //       child: ElevatedButton.icon(
  //         onPressed: () => pickAndUploadFile(context),
  //         icon: const Icon(Icons.file_upload), // Add your icon here
  //         label: const Text('Import Google Calendar'), // Your button text
  //       ),
  //     ),
  //   );
  // }
}
