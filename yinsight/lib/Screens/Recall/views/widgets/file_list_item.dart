import 'package:flutter/material.dart';


import 'package:google_fonts/google_fonts.dart';
import 'package:yinsight/Screens/Recall/animations/swipe_left_delete_animation.dart';


/// A widget that represents a file list item with selectable and deletable functionalities.
class FileListItem extends StatelessWidget {
  /// The path of the file to display.
  final String filePath;

  /// Indicates if the file is selected.
  final bool isSelected;

  /// Indicates if the selection mode is enabled.
  final bool isSelectionModeEnabled;

  /// Indicates if the delete option is enabled.
  final bool notEnableDelete;

  /// Callback function to handle file selection.
  final VoidCallback onSelected;

  /// Callback function to handle file deletion.
  final VoidCallback onDelete;

  /// Creates a [FileListItem] with the specified properties.
  ///
  /// [filePath]: The path of the file to display.
  /// [isSelected]: Indicates if the file is selected.
  /// [isSelectionModeEnabled]: Indicates if the selection mode is enabled.
  /// [notEnableDelete]: Indicates if the delete option is enabled.
  /// [onSelected]: Callback function to handle file selection.
  /// [onDelete]: Callback function to handle file deletion.
  const FileListItem({
    super.key,
    required this.filePath,
    required this.isSelected,
    required this.isSelectionModeEnabled,
    required this.notEnableDelete,
    required this.onSelected,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSelectionModeEnabled ? onSelected : null,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            
            child: ListTile(
              leading: isSelectionModeEnabled
                  ? Checkbox(
                    value: isSelected, 
                    onChanged: (_) => onSelected())
                  : const Icon(Icons.picture_as_pdf),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.all(12),
              title: Text(
                filePath.split('/').last,
                style: GoogleFonts.lexend(
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              tileColor: Colors.grey,
              trailing: notEnableDelete ? null : const SwipeLeftIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}

