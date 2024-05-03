import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yinsight/Globals/services/userInfo.dart';


import 'package:yinsight/Screens/HomePage/widgets/Calender/calenderSelection.dart';
import 'package:yinsight/Screens/Login_Signup/services/user_Authentication.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false; // Assuming a light mode by default
  UserInformation userInformation = UserInformation();
  final Uri _url = Uri.parse('https://tally.so/r/wg0x1l');
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Settings',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: const [
          // IconButton(
          //   icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.black,),
          //   onPressed: () {
          //     setState(() {
          //       isDarkMode = !isDarkMode;
          //       // Implement the actual dark/light mode switch logic here
          //     });
          //   },
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          
          children: [
            const SizedBox(height: 35),
            FutureBuilder<String>(
              future: UserInformation.getUserImage(), // Fetch the URL
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Return a loader or placeholder when the future is still loading
                  return const CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage('lib/Assets/Image_Comp/HomeImages/User.png'), // Placeholder image
                  );
                } else if (snapshot.hasData && snapshot.data != "Error fetching user data") {
                  // If data is received, use it as the profile picture
                  return CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(snapshot.data!),
                  );
                } else {
                  // Handle error or data not found case
                  return const CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage('lib/Assets/Image_Comp/HomeImages/User.png'), // Default or error image
                  );
                }
              },
            ),
            TextButton(
              /* Implement the add profile picture to the database */
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  // Pick an image
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

                  if (image != null) {
                    // Get the user token
                    final user = FirebaseAuth.instance.currentUser;
                    final String? token = await user?.getIdToken();

                    if (token == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Authentication token not found')),
                      );
                      return;
                    }

                    // Create a MultipartRequest to upload the file
                    Uri uri = Uri.parse(UserInformation.getRoute('uploadProfilePicture'));
                    var request = http.MultipartRequest('POST', uri)
                      ..files.add(await http.MultipartFile.fromPath('profile_picture', image.path))
                      ..headers.addAll({
                        "Authorization": token,
                      });

                    // Send the request
                    var response = await request.send();

                    // Handle the response
                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile picture updated successfully')),
                      );

                      // Optionally, trigger a state update to reflect the new profile picture
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update profile picture. Status code: ${response.statusCode}')),
                      );
                    }
                  }
                },
              child: const Text(
                "Add Profile Picture",
                style: TextStyle(
                  color: Colors.blue,
                ),
              )
              
            ),
            ListTile(
              leading: SvgPicture.asset(
                "lib/Assets/Image_Comp/Icons/calender.svg",
                width: 24, // Set your desired icon width
                height: 24, // Set your desired icon height
              ),
              title: const Text('Calendar Sync',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarSelectionScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.help),
              title: const Text(
                'Help & Feedback',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: _launchUrl,
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () =>  AuthServices(context).signOut(),
            ),
         
            // Add additional settings options as needed
          ],
        ),
      ),
    );
  }
}
