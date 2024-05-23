import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yinsight/Screens/Recall/views/widgets/file_list_item.dart';



/// A widget that displays a list of files with selectable and deletable functionalities.
class FileListView extends StatelessWidget {
  /// The list of file paths to display.
  final List<String> filePaths;

  /// Indicates if the delete option is enabled.
  final bool notEnableDelete;

  /// Callback function to handle file deletion.
  final Function(int) onDeleteFile;

  /// A set of selected files.
  final Set<String> selectedFiles;

  /// Indicates if the selection mode is enabled.
  final bool isSelectionModeEnabled;

  /// Callback function to handle file selection.
  final Function(int, bool) onFileSelected;

  /// Creates a [FileListView] with the specified properties.
  ///
  /// [filePaths]: The list of file paths to display.
  /// [notEnableDelete]: Indicates if the delete option is enabled.
  /// [onDeleteFile]: Callback function to handle file deletion.
  /// [selectedFiles]: A set of selected files.
  /// [isSelectionModeEnabled]: Indicates if the selection mode is enabled.
  /// [onFileSelected]: Callback function to handle file selection.
  const FileListView({
    super.key,
    required this.filePaths,
    required this.notEnableDelete,
    required this.onDeleteFile,
    required this.selectedFiles,
    required this.isSelectionModeEnabled,
    required this.onFileSelected, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filePaths.length,
      itemBuilder: (context, index) {
        return Slidable(
          key: ValueKey(filePaths[index]),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.25,
            // dismissible: DismissiblePane(onDismissed: () => onDeleteFile(index)),
            children: [
              SlidableAction(
                onPressed: (_) => onDeleteFile(index),
                backgroundColor: Colors.red,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: FileListItem(
            filePath: filePaths[index],
            isSelected: selectedFiles.contains(filePaths[index]),
            isSelectionModeEnabled: isSelectionModeEnabled,
            notEnableDelete: notEnableDelete,
            onSelected: () => onFileSelected(index, !selectedFiles.contains(filePaths[index])),
            onDelete: () {},
          ),
        );
      },
    );
  }
}
