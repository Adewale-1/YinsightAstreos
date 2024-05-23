import 'package:flutter/material.dart';

/// A service to manage dialogs.
class DialogService {

  
  /// Shows a confirmation dialog.
  ///
  /// [context]: The build context.
  /// [taskName]: The name of the task to confirm.
  ///
  /// Returns a [Future] that resolves to a boolean indicating whether the task was confirmed.
  static Future<bool?> showConfirmationDialog(
      BuildContext context, String taskName) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Start Task', style: TextStyle(color: Colors.black)),
        content: Text('Are you ready to do $taskName?',
            style: const TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            child: const Text(
              'No',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
