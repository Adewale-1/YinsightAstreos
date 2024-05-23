import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yinsight/Globals/services/userInfo.dart';

import 'package:yinsight/Screens/HomePage/widgets/settings.dart';

/// A widget to display the user's avatar and name.
class AvatarWidget extends StatelessWidget {
  AvatarWidget({super.key});
  UserInformation userInformation = UserInformation();


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            FutureBuilder<String>(
              future: UserInformation.getUserImage(), // Fetch the URL
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Return a loader or placeholder when the future is still loading
                  return const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('lib/Assets/Image_Comp/HomeImages/User.png'), // Placeholder image
                  );
                } else if (snapshot.hasData && snapshot.data != "Error fetching user data") {
                  // If data is received, use it as the profile picture
                  return CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(snapshot.data!),
                  );
                } else {
                  // Handle error or data not found case
                  return const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('lib/Assets/Image_Comp/HomeImages/User.png'), // Default or error image
                  );
                }
              },
            ),
            const SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeIn(
                  duration: const Duration(milliseconds: 900),
                  delay: const Duration(milliseconds: 250),
                  child: Text(
                    'Welcome',
                    style: GoogleFonts.lexend(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 13.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                FutureBuilder<String>(
                  future: userInformation.fetchUserData(), // Fetch the username
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                      return FadeIn( // Again, ensure FadeIn is correctly implemented or replaced
                        duration: const Duration(milliseconds: 1600),
                        delay: const Duration(milliseconds: 600),
                        child: Text(
                          snapshot.data!, // Display the fetched username
                          style: GoogleFonts.lexend(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 17.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Display a placeholder or loading indicator
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              iconSize: 50,
              icon: const Icon(Icons.settings, color: Colors.black45),
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            // GestureDetector(
            //   onTap: () {
            //       //Naviaget to the focus Screen class
            //       Navigator.push(context,
            //         MaterialPageRoute(builder: (context) => focusSection()),
            //       );
            //   },
            //   child: Container(
            //             height: 50,
            //             width: 50,
            //             decoration: BoxDecoration(
            //               borderRadius: BorderRadius.circular(20),
            //               color: Colors.grey[500],
            //             ),
            //             child: const Icon(
            //               Icons.notifications,
            //               color: Colors.black,
            //               size: 40,
            //             ),
            //           ),
            //   ),
          ],
        )

        // SizedBox(width: 10),
        
      ],
    );
  }
}