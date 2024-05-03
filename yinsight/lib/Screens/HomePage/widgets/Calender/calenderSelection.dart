import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yinsight/Screens/HomePage/widgets/Calender/googleCalender.dart';


class CalendarSelectionScreen extends StatelessWidget {
  const CalendarSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Calendar Sync",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          
          children: [
            const SizedBox(height: 35),
            _buildCalendarOption(context, "Google Calendar", FontAwesomeIcons.google, () {
              
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarDisplayScreen()));
            }),
            _buildCalendarOption(context, "Apple Calendar", FontAwesomeIcons.apple, () {
              // For now, showing a placeholder
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Coming Soon"),
                  content: const Text("This feature has not been added yet, our engineers are currently working on it."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            }),
            _buildCalendarOptionWithSVG_Icon(context, "Outlook Calendar", "lib/Assets/Image_Comp/Icons/outlook.svg", () {
              // For now, showing a placeholder
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Coming Soon"),
                  content: const Text("This feature has not been added yet, our engineers are currently working on it."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            }),
            _buildCalendarOptionWithSVG_Icon(context, "Notion Calendar","lib/Assets/Image_Comp/Icons/notion.svg", () {
              // For now, showing a placeholder
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Coming Soon"),
                  content: const Text("This feature has not been added yet, our engineers are currently working on it."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            }),
            // Add more calendar options similarly
          ],
        ),
      ),
    );
  }

  ListTile _buildCalendarOption(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }
  ListTile _buildCalendarOptionWithSVG_Icon(BuildContext context, String title, String svgIconPath, VoidCallback onTap) {
    return ListTile(
      leading: SvgPicture.asset(
        svgIconPath,
        width: 24, // Set your desired icon width
        height: 24, // Set your desired icon height
      ),
      title: Text(title,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }
}
