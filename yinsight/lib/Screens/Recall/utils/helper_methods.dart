import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:animate_do/animate_do.dart';

import 'package:yinsight/Screens/HomePage/views/home/home_screen.dart';
import 'package:yinsight/Screens/Recall/services/recall_services.dart';

/// A helper class for various recall-related UI operations.
class RecallHelpers {
  /// Displays a popup notification indicating the user can only select one file.
  ///
  /// [context]: The build context to show the dialog.
  static void popupNotificationForExceedingGenerating(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          // title: Text('Notification'),
          content: const Text(
              'You can only select 1 file.\n\nUpgrade to premium to select more files.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it!'),
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(); // Make sure to use `dialogContext` here for clarity.
              },
            ),
          ],
        );
      },
    );
  }

  /// Displays a popup notification indicating no files have been added.
  ///
  /// [context]: The build context to show the dialog.
  static void popupNotificationForEmptyDeletion(context) {
    // Using a SnackBar for the popup notification
    // const snackBar = SnackBar(
    //   content: Text('You have not added any Files'),
    //   duration: Duration(seconds: 3),
    // );
    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: const Text('You have not added any Files'),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it!'),
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(); // Make sure to use `dialogContext` here for clarity.
              },
            ),
          ],
        );
      },
    );
  }

  /// Displays a confirmation dialog for deleting a file.
  ///
  /// [context]: The build context to show the dialog.
  /// [filePaths]: The path of the file to be deleted.
  /// [index]: The index of the file to be deleted.
  /// [deleteFileCallback]: The callback function to delete the file.
  static void DeleteConfirmation(BuildContext context, String filePaths,
      int index, Function(int) deleteFileCallback) {
    String file = filePaths.split('/').last;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete Confirmation",
            style: GoogleFonts.lexend(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          content: Text("Do you want to delete $file ?"),
          actions: <Widget>[
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                deleteFileCallback(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Returns a widget indicating no files have been added.
  ///
  /// Returns a [Center] widget with a text message.
  static Center noFilesAdded() {
    return Center(
      child: Text(
        "No Files added yet",
        style: GoogleFonts.lexend(
          textStyle: const TextStyle(
            color: Colors.black54,
            fontSize: 18.0,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Displays a popup notification indicating a file has already been added.
  ///
  /// [context]: The build context to show the dialog.
  static void popupNotificationForDuplicates(context) {
    // Using a SnackBar for the popup notification
    // const snackBar = SnackBar(
    //   content: Text('You have already added this File'),
    //   duration: Duration(seconds: 3),
    // );
    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          // title: Text('Notification'),
          content: const Text('You have already added this File'),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it!'),
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(); // Make sure to use `dialogContext` here for clarity.
              },
            ),
          ],
        );
      },
    );
  }

  /// Displays a popup notification indicating no files have been added for generation.
  ///
  /// [context]: The build context to show the dialog.
  static void popupNotificationForEmptyGeneration(context) {
    // Using a SnackBar for the popup notification
    const snackBar = SnackBar(
      content: Text('You have not added any Files'),
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          // title: Text('Notification'),
          content: const Text('You have not added any Files'),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it!'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Returns a widget with a fade-up animation for adding a file.
  ///
  /// [addFileCallback]: The callback function to add a file.
  ///
  /// Returns a [FadeInUp] widget.
  static Widget fadeUpWidget(VoidCallback addFileCallback) {
    return FadeInUp(
      duration: const Duration(milliseconds: 900),
      delay: const Duration(milliseconds: 250),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 70,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Colors.black,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: addFileCallback,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: GoogleFonts.lexend(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.upload_file,
                      size: 30.0,
                    ),
                    SizedBox(width: 10),
                    Text('Upload File'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigates back to the home screen.
  ///
  /// [context]: The build context to navigate.
  static void backToHomeScreen(void Function(int index) onSectionTap, context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(onSectionTap: onSectionTap),
      ),
    );
  }

  /// Proceeds with the selected files and shows a confirmation dialog.
  ///
  /// [selectedFiles]: The set of selected files.
  /// [context]: The build context to show the dialog.
  /// [onProceedConfirmed]: The callback function to proceed with the selected files.
  static void proceedWithSelectedFiles(
      Set<String> selectedFiles,
      BuildContext context,
      VoidCallback onProceedConfirmed,
      Future<void> Function() onGenerationComplete) {
    _generateQuestionsConfirmation(
        context, selectedFiles, onProceedConfirmed, onGenerationComplete);
  }

  /// Displays a confirmation dialog for generating questions.
  ///
  /// [context]: The build context to show the dialog.
  /// [selectedFiles]: The set of selected files.
  /// [onProceedConfirmed]: The callback function to proceed with the selected files.
  static void _generateQuestionsConfirmation(
      BuildContext context,
      Set<String> selectedFiles,
      VoidCallback onProceedConfirmed,
      Future<void> Function() onGenerationComplete) {
    Set<String> filesCopy = Set.from(selectedFiles);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Generate Flashcards Confirmation"),
          content: Text(
              "Do you want to generate questions from ${selectedFiles.length} files?"),
          actions: <Widget>[
            TextButton(
              child: const Text("No"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () async {
                Navigator.of(context).pop();
                onProceedConfirmed();
                await showGenerationProgressDialog(context);
                var userToken =
                    await FirebaseAuth.instance.currentUser?.getIdToken();
                if (userToken != null) {
                  bool success =
                      await RecallServices.generateQuestions(filesCopy);
                  if (success) {
                    await onGenerationComplete();
                  } else {
                    // Handle the case where generation was not successful
                    print("Question generation was not successful");
                    // You might want to show an error message to the user here
                  }
                } else {
                  print("User token not found, unable to generate questions.");
                  // You might want to show an error message to the user here
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Displays a progress dialog for generating questions.
  ///
  /// [context]: The build context to show the dialog.
  ///
  /// Returns a [Future] that completes when the dialog is dismissed.
  static Future<void> showGenerationProgressDialog(BuildContext context) async {
    bool shouldCloseDialog = true;

    // Using StatefulBuilder to handle state within the dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          // Setup a timer to close the dialog after 2 seconds
          Future.delayed(const Duration(seconds: 28), () {
            if (shouldCloseDialog) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          });

          return AlertDialog(
            title: const Text("Hang Tight!"),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Do not navigate away from this screen till your question has been generated, it is estimated to take 27 seconds. You'll get a notification when it's done.",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Got it!"),
                onPressed: () {
                  shouldCloseDialog =
                      false; // Prevent automatic closure if manually dismissed
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  /// Generates questions from the selected files.
  ///
  /// [selectedFiles]: The set of selected files.
  /// [onCompleted]: The callback function to call when generation is completed.
  /// [context]: The build context.
  static void generateQuestions(Set<String> selectedFiles,
      VoidCallback onCompleted, BuildContext context) {
    RecallServices.generateQuestions(selectedFiles).then((_) {
      // All files uploaded successfully
      // print("All files uploaded successfully");
      onCompleted(); // Call the completion callback here
    }).catchError((error) {
      // Handle any upload errors here
      // print('Error uploading files: $error');
    });
  }

  // static void DeleteAllConfirmation(BuildContext context,
  //     List<String> filePaths, VoidCallback deleteAllCallback) {
  //   print(
  //       ">>>>>>>>>>>>.. .......... Delete all confirmation .......... <<<<<<<<<<<<");
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(
  //           "Generate Flashcards Confirmation",
  //           style: GoogleFonts.lexend(
  //             textStyle: const TextStyle(
  //               color: Colors.white,
  //               fontSize: 15.0,
  //               fontWeight: FontWeight.normal,
  //             ),
  //           ),
  //         ),
  //         content: Text(
  //           filePaths.isEmpty
  //               ? "No files to delete"
  //               : "Delete  ${filePaths.length} files?",
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text("No"),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text("Yes"),
  //             onPressed: () {
  //               deleteAllCallback();
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
