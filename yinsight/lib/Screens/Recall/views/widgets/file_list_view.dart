import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yinsight/Screens/Recall/views/widgets/file_list_item.dart';




class FileListView extends StatelessWidget {
  final List<String> filePaths;
  final bool notEnableDelete;
  final Function(int) onDeleteFile;
  final Set<String> selectedFiles;
  final bool isSelectionModeEnabled;
  final Function(int, bool) onFileSelected; // Add this line

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
