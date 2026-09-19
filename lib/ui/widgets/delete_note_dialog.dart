import 'package:flutter/material.dart';
import 'confirm_dialog.dart';

/// Standardized, reusable confirmation dialog for deleting a note.
///
/// Ensures consistent UX, styling, and copy between the note card and
/// the note edit screen.
class DeleteNoteDialog extends StatelessWidget {
  final String noteTitle;
  final bool isLoading;
  final VoidCallback? onConfirm;

  const DeleteNoteDialog({
    super.key,
    required this.noteTitle,
    this.isLoading = false,
    this.onConfirm,
  });

  /// Shows the delete confirmation dialog and returns whether the user confirmed deletion.
  static Future<bool> show(
    BuildContext context, {
    required String noteTitle,
    bool isLoading = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: !isLoading,
      builder: (context) => DeleteNoteDialog(
        noteTitle: noteTitle,
        isLoading: isLoading,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        noteTitle.trim().isNotEmpty ? noteTitle.trim() : 'this note';

    return ConfirmDialog(
      title: 'Delete Note',
      message:
          'Are you sure you want to delete "$displayName"? This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
      isLoading: isLoading,
      onConfirm: onConfirm ?? () => Navigator.of(context).pop(true),
    );
  }
}
