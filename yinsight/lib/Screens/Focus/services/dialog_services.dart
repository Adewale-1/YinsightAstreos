import 'package:flutter/material.dart';

class DialogService {
  static Future<bool?> showConfirmationDialog(
      BuildContext context, String taskName) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Start Task', style: TextStyle(color: Colors.black)),
        content: Text('Are you ready to do $taskName?',
            style: const TextStyle(color: Colors.black)
        ),
        actions: [
          TextButton(
            child: const Text('No',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Yes',
              style: TextStyle(color: Colors.black),
            
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
