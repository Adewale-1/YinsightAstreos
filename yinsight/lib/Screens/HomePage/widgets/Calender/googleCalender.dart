
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:yinsight/Globals/services/userInfo.dart';
import 'package:yinsight/Screens/HomePage/widgets/Calender/eventsCalender.dart';



class CalendarDisplayScreen extends StatefulWidget {
  const CalendarDisplayScreen({super.key});

  @override
  _CalendarDisplayScreenState createState() => _CalendarDisplayScreenState();
}



class _CalendarDisplayScreenState extends State<CalendarDisplayScreen> {


Future<void> pickAndUploadFile(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  String? token = await user?.getIdToken();
  if (token == null) throw Exception('No token found');

  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    Uri uri = Uri.parse(UserInformation.getRoute('updateISOCalendar'));
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', result.files.single.path!))
      ..headers.addAll({
        "Authorization": token,
      });

    var response = await request.send();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calendar imported successfully! Processing events...')),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const GoogleCalendarClass()),
      );
    } else {
      var responseBody = await response.stream.bytesToString();
      // print('Error response: $responseBody');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to import calendar.')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File selection cancelled')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Google Calendar Sync",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => pickAndUploadFile(context),
          icon: const Icon(Icons.file_upload), // Add your icon here
          label: const Text('Import Google Calendar'), // Your button text
        ),
      ),
    );
  }
}
