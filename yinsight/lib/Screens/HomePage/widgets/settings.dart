import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yinsight/Globals/services/userInfo.dart';
import 'package:yinsight/Screens/HomePage/widgets/Calender/calenderSelection.dart';
import 'package:yinsight/Screens/Login_Signup/services/user_Authentication.dart';

/// A screen that provides various settings options for the user.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}



class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  UserInformation userInformation = UserInformation();
  final Uri _url = Uri.parse('https://tally.so/r/wg0x1l');
  File? _localImage;

  /// Launches the feedback URL.
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  int _reloadImageKey = 0;

  Future<String> _getUserImage() {
    return UserInformation.getUserImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: const [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 35),
            FutureBuilder<String>(
              future: _getUserImage(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (_localImage != null) {
                  return CircleAvatar(
                    radius: 70,
                    backgroundImage: FileImage(_localImage!),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircleAvatar(
                    radius: 70,
                    backgroundImage:
                        AssetImage('lib/Assets/Image_Comp/HomeImages/User.png'),
                  );
                } else if (snapshot.hasData &&
                    snapshot.data != "Error fetching user data") {
                  // Append a unique parameter to force image refresh
                  String imageUrl = snapshot.data! + '?v=$_reloadImageKey';
                  return CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(imageUrl),
                  );
                } else {
                  return const CircleAvatar(
                    radius: 70,
                    backgroundImage:
                        AssetImage('lib/Assets/Image_Comp/HomeImages/User.png'),
                  );
                }
              },
            ),
            TextButton(
              onPressed: () async {
                try {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);

                  if (image != null) {
                    setState(() {
                      _localImage = File(image.path);
                    });

                    final user = FirebaseAuth.instance.currentUser;
                    final String? token = await user?.getIdToken();

                    if (token == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Authentication token not found')),
                      );
                      return;
                    }

                    Uri uri = Uri.parse(
                        UserInformation.getRoute('uploadProfilePicture'));
                    var request = http.MultipartRequest('POST', uri)
                      ..files.add(await http.MultipartFile.fromPath(
                          'profile_picture', image.path))
                      ..headers.addAll({
                        "Authorization": token,
                      });

                    var response = await request.send();

                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Profile picture updated successfully')),
                      );

                      final imageUrl = await UserInformation.getUserImage();
                      PaintingBinding.instance.imageCache
                          .evict(NetworkImage(imageUrl));

                      setState(() {
                        _localImage = null;
                        _reloadImageKey++;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Failed to update profile picture. Status code: ${response.statusCode}')),
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('An error occurred: $e')),
                  );
                }
              },
              child: const Text(
                "Add Profile Picture",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
            ListTile(
              leading: SvgPicture.asset(
                "lib/Assets/Image_Comp/Icons/calender.svg",
                width: 24, // Set your desired icon width
                height: 24, // Set your desired icon height
              ),
              title: const Text(
                'Calendar Sync',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CalendarSelectionScreen()),
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
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () => AuthServices(context).signOut(),
            ),

            // Add additional settings options as needed
          ],
        ),
      ),
    );
  }
}
