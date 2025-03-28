import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:yinsight/Globals/services/userInfo.dart';
import 'package:yinsight/Screens/Recall/services/localPushNotification.dart';
import 'package:yinsight/Screens/Recall/services/recallWelcome.dart';
import 'package:yinsight/Screens/Recall/utils/helper_methods.dart';
import 'package:yinsight/Screens/Recall/views/question_screen.dart';
import 'package:yinsight/Screens/Recall/views/widgets/file_list_view.dart';
import 'package:http/http.dart' as http;

/// A widget that provides the main interface for the Recall feature.
class Recall extends StatefulWidget {
  const Recall({super.key});

  @override
  State<Recall> createState() => _RecallState();
}

class _RecallState extends State<Recall> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final WelcomeService _welcomeService;

  List<String> filePaths = []; // List to store file paths
  Set<String> selectedFiles = <String>{}; // Set to track selected files
  bool isSelectionModeEnabled = false; // To track if selection mode is enabled
  String? selectedFilePath;
  bool notEnableDelete = false;
  bool showCancelOption = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  OverlayEntry? _overlayEntry;
  String activity1 = "fileUpload";
  String activity2 = "flashcardGeneration";

  final bool _isDialogShown = false;

  @override
  void initState() {
    super.initState();
    _fetchUploadedFiles();
    _setupAnimation();
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationService.onActionReceivedMethod,
        onDismissActionReceivedMethod:
            NotificationService.onDismissActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationService.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationService.onNotificationDisplayedMethod);
    _welcomeService = WelcomeService(_scaffoldKey);
    _welcomeService.checkAndShowWelcomeDialog();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Shows a confirmation dialog for deleting all files.
  ///
  /// [context]: The build context.
  void _deleteAllConfirmation(BuildContext context) {
    if (filePaths.isEmpty) {
      RecallHelpers.popupNotificationForEmptyDeletion(context);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Confirmation"),
          content: const Text("Do you want to delete all selected files?"),
          actions: <Widget>[
            TextButton(
              child: const Text("No"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                _deleteAll();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Deletes all files.
  void _deleteAll() {
    setState(() {
      filePaths.clear();
      selectedFiles.clear();
    });
  }

  /// Creates a widget for navigating back to the home screen.
  ///
  /// [context]: The build context.
  ///
  /// Returns a [FloatingActionButton].
  Widget _backToHomeScreenWidget(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.of(context).pop(),
      backgroundColor: Colors.white,
      child: const Icon(Icons.chevron_left, size: 40, color: Colors.black),
    );
  }

  Future<void> _onGenerationComplete() async {
    await _checkAndUpdatePoints(activity2);
  }

  /// Deletes a file at the specified index.
  ///
  /// [index]: The index of the file to delete.
  Future<void> _onDeleteFile(int index) async {
    final String fileName = filePaths[index];

    final String url =
        '${UserInformation.getRoute('deletePDF')}?file_name=$fileName';

    final user = FirebaseAuth.instance.currentUser;
    String? token = await user?.getIdToken();

    if (token == null) {
      // print('No token found');
      return;
    }

    // print('Deleting file: $url');

    try {
      // print('Deleting file with url: $url');
      var response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': token,
        },
      );
      // print('Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        // print("File with name $fileName deleted successfully.");
        setState(() {
          filePaths.removeAt(index);
        });
        // Show a success message to the user
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('File successfully deleted!')),
        // );
      } else {
        // print('Failed to delete file: ${response.statusCode} - ${response.body}');
        // Show an error message to the user
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to delete file: ${response.statusCode} - ${response.body}')),
        // );
      }
    } catch (e) {
      // print('Error deleting file: $e');
      // Show an error message to the user
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error deleting file: $e')),
      // );
    }
  }

  // void _handleFileSelection(int index, bool isSelected) {
  //   setState(() {
  //     if (isSelected) {
  //       if (selectedFiles.isEmpty) {
  //         selectedFiles.add(filePaths[index]);
  //       } else {
  //         RecallHelpers.popupNotificationForExceedingGenerating(context);
  //       }
  //     } else {
  //       selectedFiles.remove(filePaths[index]);
  //     }
  //   });
  // }

  /// Handles file selection.
  ///
  /// [context]: The build context.
  /// [index]: The index of the file to select.
  /// [isSelected]: Whether the file is selected.
  void _handleFileSelection(BuildContext context, int index, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (selectedFiles.isEmpty) {
          selectedFiles.add(filePaths[index]);
        } else {
          RecallHelpers.popupNotificationForExceedingGenerating(context);
        }
      } else {
        selectedFiles.remove(filePaths[index]);
      }
    });
  }

  /// Builds the content of the drawer.
  ///
  /// [filePaths]: The list of file paths.
  /// [context]: The build context.
  ///
  /// Returns a [Drawer] widget.
  Widget _drawerContent(List<String> filePaths, BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.question_answer_sharp, color: Colors.white),
              title: const Text('Show Questions',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                // if (filePaths.isEmpty) {
                //   RecallHelpers.popupNotificationForEmptyDeletion(context);
                // } else {
                //   _deleteAllConfirmation();
                // }

                // Navigator.of(context).pop();
                // Navgate to the Question.dart
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuestionsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_answer, color: Colors.white),
              title: const Text('Generate Flashcards',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                if (filePaths.isEmpty) {
                  // Show a popup notification
                  RecallHelpers.popupNotificationForEmptyGeneration(context);
                } else {
                  setState(() {
                    showCancelOption = true;
                    isSelectionModeEnabled = true;
                    notEnableDelete = true;
                  });
                }
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Adds a file to the list of file paths.
  Future<void> _addFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        String? pickedFilePath = result.files.single.path;

        if (pickedFilePath != null && !_fileAlreadyExists(pickedFilePath)) {
          setState(() => filePaths.insert(0, pickedFilePath));
          await _uploadFile(pickedFilePath);
        }
      } else {
        // print("File picking cancelled.");
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error picking file: $e')),
      // );
    }
  }

  void _showTransitionGif() {
    // Use a post-frame callback to ensure we have a valid context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Check if the widget is still in the tree

      _overlayEntry = OverlayEntry(
        builder: (BuildContext context) => AnimatedBuilder(
          animation: _animation,
          builder: (BuildContext context, Widget? child) {
            return Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5 * _animation.value),
                child: Center(
                  child: Image.asset(
                    'lib/Assets/Image_Comp/Icons/singleCoin.gif',
                    width: 100 + (50 * _animation.value),
                    height: 100 + (50 * _animation.value),
                  ),
                ),
              ),
            );
          },
        ),
      );

      Overlay.of(this.context).insert(_overlayEntry!);
      _animationController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _animationController.reverse().then((_) {
            _overlayEntry?.remove();
            _overlayEntry = null;
          });
        });
      });
    });
  }

  /// Uploads a file to the server.
  ///
  /// [filePath]: The path of the file to upload.
  Future<void> _uploadFile(String filePath) async {
    final user = FirebaseAuth.instance.currentUser;
    String? token = await user?.getIdToken();

    if (token == null) throw Exception('No token found');
    var uri = Uri.parse(UserInformation.getRoute('recallFileUpload'));
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = token
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: basename(filePath),
      ));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        await _fetchUploadedFiles(); // Fetch the updated list of uploaded files
        await _checkAndUpdatePoints(activity1);
      } else {
        throw Exception('Failed to upload file');
      }
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  Future<void> _checkAndUpdatePoints(String activity) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      String? token = await user?.getIdToken();
      if (token == null) {
        print("No token found");
        return;
      }

      final url =
          '${UserInformation.getRoute('checkForPoints')}/?activity=$activity';
      final httpClient = HttpClient();
      try {
        final request = await httpClient.getUrl(Uri.parse(url));
        request.headers.set('Authorization', token);

        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();

        if (response.statusCode == 200) {
          final data = json.decode(responseBody);
          final pointsEarned = data['points_earned'];
          final lastOpenedDateTime = data['dateOfLastActivity'];

          if (lastOpenedDateTime != null) {
            final lastOpenedDate = DateTime.parse(lastOpenedDateTime).toLocal();
            final currentDate = DateTime.now().toLocal();
            print("Points earned is : $pointsEarned");
            print("Current date is $currentDate");
            print(
                "Difference is : ${currentDate.difference(lastOpenedDate).inDays}");

            // Check points based on activity
            if (activity == "fileUpload") {
              if (currentDate.difference(lastOpenedDate).inDays == 0 &&
                  pointsEarned == 1.0) {
                print(
                    'Points already allocated today for file upload, not showing animation');
                return;
              }
            } else if (activity == "flashcardGeneration") {
              if (currentDate.difference(lastOpenedDate).inDays == 0 &&
                  pointsEarned == 1.5) {
                print(
                    'Points already allocated today for flashcard generation, not showing animation');
                return;
              }
            }
          }

          print('Updating daily activity and showing animation');
          await _updateDailyActivityAndStreak(activity);
          _showTransitionGif();
        } else {
          print('Failed to check points: ${response.statusCode}');
          print('Response body: $responseBody');
        }
      } finally {
        httpClient.close();
      }
    } catch (e, stackTrace) {
      print('Error checking points: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _updateDailyActivityAndStreak(String activity) async {
    final user = FirebaseAuth.instance.currentUser;
    String? token = await user?.getIdToken();

    if (token == null) {
      throw Exception('No token found');
    }

    final httpClient = HttpClient();
    try {
      final request = await httpClient
          .postUrl(Uri.parse(UserInformation.getRoute('allocatePoints')));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, token);
      request.add(utf8.encode(json.encode({'activity': activity})));

      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Failed to update daily activity and streak');
      }
    } finally {
      httpClient.close();
    }
  }

  /// Fetches the uploaded files from the server.
  Future<void> _fetchUploadedFiles() async {
    final user = FirebaseAuth.instance.currentUser;
    String? token = await user?.getIdToken();

    if (token == null) throw Exception('No token found');

    var uri = Uri.parse(UserInformation.getRoute('getPDFs'));
    var response = await http.get(uri, headers: {
      'Authorization': token,
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<String> files = List<String>.from(data['files']);
      print('Files: $files');
      setState(() {
        filePaths = files;
      });
    } else {
      throw Exception('Failed to fetch files');
    }
  }

  /// Checks if a file already exists in the list of file paths.
  ///
  /// [filePath]: The path of the file to check.
  ///
  /// Returns true if the file already exists, false otherwise.
  bool _fileAlreadyExists(String filePath) {
    if (filePaths.contains(filePath)) {
      RecallHelpers.popupNotificationForDuplicates(context);
      return true;
    }
    return false;
  }

  /// Resets the state of the widget.
  void _resetState() {
    setState(() {
      selectedFiles.clear();
      isSelectionModeEnabled = false;
      showCancelOption = false;
      notEnableDelete = false; // Reset other flags as needed
    });
  }

  /// Builds the app bar.
  ///
  /// [context]: The build context.
  ///
  /// Returns an [AppBar] widget.
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      actions: selectedFiles.isNotEmpty
          ? [
              // Text button called Undo and another called Proceed
              TextButton(
                onPressed: () {
                  setState(() {
                    showCancelOption = false;
                    notEnableDelete = false;
                    selectedFiles.clear();
                    isSelectionModeEnabled =
                        false; // Optional, to exit selection mode
                  });
                },
                child: Text(
                  "Undo",
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Colors.blue,
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Implement the logic for Proceed
                  RecallHelpers.proceedWithSelectedFiles(selectedFiles, context,
                      _resetState, _onGenerationComplete);
                },
                child: Text(
                  "Proceed",
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Colors.blue,
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ]
          : showCancelOption && filePaths.isNotEmpty
              ? [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showCancelOption = false;
                        notEnableDelete = false;
                        selectedFiles.clear();
                        isSelectionModeEnabled = false;
                      });
                    },
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.lexend(
                        textStyle: const TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  )
                ]
              : null,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.menu,
          color: Colors.black,
        ),
        onPressed: () {
          _scaffoldKey.currentState!.openDrawer();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      drawer: _drawerContent(filePaths, context),
      body: Stack(
        children: [
          filePaths.isEmpty
              ? RecallHelpers.noFilesAdded()
              : Padding(
                  padding: const EdgeInsets.only(bottom: 70.0),
                  child: FileListView(
                    filePaths: filePaths,
                    notEnableDelete: notEnableDelete,
                    onDeleteFile: _onDeleteFile,
                    selectedFiles: selectedFiles,
                    isSelectionModeEnabled: isSelectionModeEnabled,
                    onFileSelected: (index, isSelected) =>
                        _handleFileSelection(context, index, isSelected),
                  ),
                ),
          RecallHelpers.fadeUpWidget(_addFile),
        ],
      ),
    );
  }
}
