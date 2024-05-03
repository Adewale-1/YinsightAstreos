import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yinsight/Globals/services/userInfo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class FocusCard extends StatefulWidget {
  final double height;

  const FocusCard({super.key, required this.height});

  @override
  _FocusCardState createState() => _FocusCardState();
}

class _FocusCardState extends State<FocusCard> {
  Future<int> fetchNumberOfTasksCreated() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    if (token == null) {
      throw Exception('No token found');
    }
    final response = await http.get(
      Uri.parse(UserInformation.getRoute('NumberOfTasksCreated')),
      headers: {
        'Authorization': token,
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['total_number_of_tasks'];
    } else {
      throw Exception('Failed to load task count');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.blue,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Focus',
            style: GoogleFonts.lexend(
              textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(),
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FutureBuilder<int>(
                        future: fetchNumberOfTasksCreated(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data.toString(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const Text(
                              '?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Current Missions',
                        style: GoogleFonts.lexend(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}