import 'package:flutter/material.dart';
import 'confirm_dialog.dart';

/// Standardized, reusable confirmation dialog for deleting a note.
///
/// Ensures consistent UX, styling, and copy between the note card and
/// the note edit screen, including an active loading state during async deletion.
class DeleteNoteDialog extends StatefulWidget {
  final String noteTitle;
  final bool isLoading;
  final VoidCallback? onConfirm;
  final Future<dynamic> Function()? onDelete;

  const DeleteNoteDialog({
    super.key,
    required this.noteTitle,
    this.isLoading = false,
    this.onConfirm,
    this.onDelete,
  });

  /// Shows the delete confirmation dialog and returns whether the user confirmed deletion.
  ///
  /// If [onDelete] is supplied, the dialog remains open during deletion,
  /// displays an active loader in the Delete button, disables the Cancel button,
  /// and prevents accidental dismissal until the deletion completes.
  static Future<bool> show(
    BuildContext context, {
    required String noteTitle,
    bool isLoading = false,
    Future<dynamic> Function()? onDelete,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: !isLoading,
      builder: (context) => DeleteNoteDialog(
        noteTitle: noteTitle,
        isLoading: isLoading,
        onDelete: onDelete,
      ),
    );
    return result ?? false;
  }

  @override
  State<DeleteNoteDialog> createState() => _DeleteNoteDialogState();
}

class _DeleteNoteDialogState extends State<DeleteNoteDialog> {
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading;
  }

  Future<void> _handleConfirm() async {
    if (_isLoading) return;

    if (widget.onDelete != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final res = await widget.onDelete!();
        if (!mounted) return;
        final bool isSuccess = res is bool ? res : (res is String ? false : true);
        Navigator.of(context).pop(isSuccess);
      } catch (_) {
        if (!mounted) return;
        Navigator.of(context).pop(false);
      }
    } else if (widget.onConfirm != null) {
      widget.onConfirm!();
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        widget.noteTitle.trim().isNotEmpty ? widget.noteTitle.trim() : 'this note';

    return ConfirmDialog(
      title: 'Delete Note',
      message:
          'Are you sure you want to delete "$displayName"? This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
      isLoading: _isLoading,
      onConfirm: _handleConfirm,
    );
  }
}
