import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yinsight/Globals/services/userInfo.dart';
import 'package:yinsight/Screens/HomePage/models/task_model.dart';
import 'package:yinsight/Screens/HomePage/widgets/TaskNotes/textForm.dart';


class AddTaskPage extends ConsumerStatefulWidget {
  const AddTaskPage({super.key});

  @override
  ConsumerState<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends ConsumerState<AddTaskPage> {
  // final TextEditingController _selectedHour = TextEditingController();
  // final TextEditingController _selectedMinute = TextEditingController();
  int? _selectedHour;
  int? _selectedMinute;
  final List<int> _hours = List<int>.generate(24, (int index) => index); // 0 to 23 hours
  final List<int> _minutes = List<int>.generate(60, (int index) => index); // 0 to 59 minutes

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  void _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isSeventhTime = (prefs.getBool('isSeventhTime') ?? true);
    
    if (isSeventhTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog();
      });
      await prefs.setBool('isSeventhTime', false);
    }
  }
  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Welcome!😀"),
          content: const Text(
            "🗓️ Let's Get Tasking! 🗓️\n\n"
            "Ready to conquer your to-dos? Start by creating a task right here! Add notes to capture the essentials and never miss a beat 📝.\n\n"
            "Got a plan for later? Use the 'Schedule for Later' dropdown to set your task aside for future dates—it'll stay out of your current list to keep today's focus clear.\n\n"
            "Prioritize like a pro 🌟 Set a priority level to tackle tasks in order of importance. Estimate the effort with an expected duration, and watch those productivity points pile up! 🕒\n\n"
            "Ready, set, task!"
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Got It!"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  String? _selectedReminder;
  String _selectedPriority = 'None';
  List<String> reminderOptions = ['5 min', '10 min', '15 min', '20 min'];
  bool _scheduleForLater = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _assignedDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();


  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }


  Future<void> saveTask(Task task) async {
    var url = Uri.parse(UserInformation.getRoute('createTask')); // Change to your actual endpoint URL
    final user = FirebaseAuth.instance.currentUser;
    String? token = await user?.getIdToken();

    if (token == null) throw Exception('No token found');

    try {
      var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
    
        body: jsonEncode({'task': task.toJson()}),

      );

      if (response.statusCode == 200) {
        // Successfully saved
        // print('Task saved successfully');
      } else {
        // Handle error
        // print('Failed to save task: ${response.body}');
      }
    } catch (e) {
      // print('Error saving task: $e');
    }
  }




  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2125),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _assignedDateController.text = DateFormat('MM/dd/yyyy').format(pickedDate);
      });
    }
  }


  Future<void> _pickTime(BuildContext context, {required bool isStartTime}) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        final formattedTime = pickedTime.format(context);
        if (isStartTime) {
          _selectedStartTime = pickedTime;
          _startTimeController.text = formattedTime;
        } else {
          _selectedEndTime = pickedTime;
          _endTimeController.text = formattedTime;
        }
      });
    } else {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = null;
          _startTimeController.clear();
        } else {
          _selectedEndTime = null;
          _endTimeController.clear();
        }
      });
    }
  }
  
  
  String formatDuration(TimeOfDay duration) {
    final hours = duration.hour.toString().padLeft(2, '0');
    final minutes = duration.minute.toString().padLeft(2, '0');
    return "$hours hours $minutes minutes";
  }

  Duration? getSelectedDuration() {
    if (_selectedHour == null || _selectedMinute == null) {
      return null;
    }
    return Duration(hours: _selectedHour!, minutes: _selectedMinute!);
  }


  Widget _priorityButton(String text, IconData icon, String value) {
    final bool isSelected = _selectedPriority == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        avatar: Icon(icon, size: 16.0, color: isSelected ? Colors.white : Colors.black),
        label: Text(text, style: GoogleFonts.lexend(color: isSelected ? Colors.white : Colors.black)),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedPriority = value;
          });
        },
        backgroundColor: Colors.grey[700],
        selectedColor: Colors.red,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.all(4.0),
        showCheckmark: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Task',
                style: GoogleFonts.lexend(
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              InputField(
                title: "Title",
                hint: "Enter title here",
                controller: _titleController,
              ),
              InputField(
                title: "Note",
                hint: "Enter note here",
                controller: _noteController, 
              ),
              const SizedBox(height: 20),
              Text(
                "Expected Duration",
                style: GoogleFonts.lexend(
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[


                    Container(
                      width: 90,
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Adjust padding to control the dropdown's inner spacing
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black), // Set border color here
                        borderRadius: BorderRadius.circular(5), // Optionally round the corners
                      ),
                      child: DropdownButton<int>(
                        
                        dropdownColor: Colors.white,
                      
                        // hint: const Text("Hour"),
                        value: _selectedHour,
                        items: _hours.map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString(), style: const TextStyle(color: Colors.black)),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedHour = newValue;
                          });
                        },
                      ),
                    ),

                  const Text("hours", style: TextStyle(color: Colors.black)),

                    Container(
                      width: 90,
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Adjust padding to control the dropdown's inner spacing
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black), // Set border color here
                        borderRadius: BorderRadius.circular(5), // Optionally round the corners
                      ),
                      child: DropdownButtonHideUnderline( // Use this widget to remove the underline of the dropdown button
                        child: DropdownButton<int>(
                          isExpanded: true, // Makes the dropdown button expand to fill the container
                          dropdownColor: Colors.white,
                          // hint: const Text("Minute", style: TextStyle(color: Colors.black)),
                          value: _selectedMinute,
                          items: _minutes.map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString(), style: const TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedMinute = newValue;
                            });
                          },
                          style: const TextStyle(color: Colors.black), // Set the style for the dropdown items
                          iconEnabledColor: Colors.black, // Set the icon (arrow) color
                        ),
                      ),
                    ),

                  const Text("minutes", style: TextStyle(color: Colors.black)),
                ],
              ),

              ListTile(
                title: const Text("Schedule for Later",style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),),
                trailing: Icon(_scheduleForLater ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Colors.black, size: 30,),
                onTap: () {
                  setState(() {
                    _scheduleForLater = !_scheduleForLater;
                  });
                },
              ),
              if (_scheduleForLater) ...[
                _buildScheduleForLaterSection(),
              ],
              Container(
                margin: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Priority",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Center(
                      child: Wrap(
                        children: [
                          _priorityButton('Low', Icons.low_priority, 'Low'),
                          _priorityButton('Medium', Icons.priority_high, 'Medium'),
                          _priorityButton('High', Icons.warning, 'High'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
        
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Closes the current screen and returns to the previous one
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_titleController.text.isEmpty) {
                        // Handle empty title case appropriately
                        return;
                      }
                      
                      // Convert _selectedPriority string to TaskPriority enum
                      TaskPriority priorityEnum;
                      switch (_selectedPriority) {
                        case 'Low':
                          priorityEnum = TaskPriority.low;
                          break;
                        case 'Medium':
                          priorityEnum = TaskPriority.medium;
                          break;
                        case 'High':
                          priorityEnum = TaskPriority.high;
                          break;
                        default:
                          priorityEnum = TaskPriority.low; // Default case if nothing matches
                      }
                      String formattedExpectedTime = '';
                      if (_selectedHour != null && _selectedMinute != null) {
                        formattedExpectedTime = "${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}";
                      } else {
                        // Handle cases where hour or minute is not selected
                        // You might want to alert the user or provide default values
                      }
                      Task newTask = Task(
                        id: UniqueKey().toString(),
                        name: _titleController.text,
                        priority: priorityEnum, // Use the converted enum
                        notes: _noteController.text,
                        assignedDate: _selectedDate,
                        startTime: _selectedStartTime,
                        endTime: _selectedEndTime,
                        expectedTimeToComplete: formattedExpectedTime,
                        actualTimeToComplete: '', // Consider what default or placeholder to use
                        totalTimeSpent: '00:00:00',      // Consider what default or placeholder to use
                        recurrence: '',            // Initialize with an actual reminder value or manage as required
                      );


                      // Continue with your existing logic...
                      await saveTask(newTask);
                      Navigator.of(context).pop(newTask);  // Ensure this usage fits your navigation design

                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

TimeOfDay? parseTimeOfDay(String? timeString) {
  if (timeString == null || timeString.isEmpty) return null;
  final parts = timeString.split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

  Widget _buildScheduleForLaterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        InputField(
          onTap: () => _pickDate(context),
          title: "Date",
          controller: _assignedDateController,
          hint: _selectedDate != null ? DateFormat('MM/dd/yyyy').format(_selectedDate!) : DateFormat('MM/dd/yyyy').format(DateTime.now()),
          widget: const Icon(Icons.calendar_today_outlined, color: Colors.black,),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(

              child: InputField(
                onTap: () => _pickTime(context, isStartTime: true),
                title: "Start Time",
                hint:_selectedEndTime?.format(context) ?? '',
                widget: const Icon(Icons.access_time,color: Colors.black),
                controller: _startTimeController,
              ),

            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 0, 0),
                child: InputField(
                  onTap: () => _pickTime(context, isStartTime: false), // Corrected this line
                  title: "End Time",
                  controller: _endTimeController,
                  // hint: _selectedEndTime != null ? _selectedEndTime.format(context) :,
                  hint: _selectedEndTime?.format(context) ?? '',
                  widget: const Icon(Icons.access_time, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Remind",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Choose a reminder',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                value: _selectedReminder,
                items: reminderOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedReminder = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

}
