import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/note_model.dart';
import '../../../providers/notes_provider.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/delete_note_dialog.dart';
import '../../widgets/primary_button.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteModel? note;
  final NoteCategory? initialCategory;

  const AddEditNoteScreen({super.key, this.note, this.initialCategory});

  bool get isEditing => note != null;

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late NoteCategory _selectedCategory;
  late bool _isFavorite;

  late final String _initialTitle;
  late final String _initialContent;
  late final NoteCategory _initialCategory;
  late final bool _initialFavorite;

  bool _lastHasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _initialTitle = widget.note?.title ?? '';
    _initialContent = widget.note?.content ?? '';
    _initialCategory =
        widget.note?.category ?? widget.initialCategory ?? NoteCategory.personal;
    _initialFavorite = widget.note?.isFavorite ?? false;

    _titleController = TextEditingController(text: _initialTitle);
    _contentController = TextEditingController(text: _initialContent);
    _selectedCategory = _initialCategory;
    _isFavorite = _initialFavorite;

    _titleController.addListener(_checkChanges);
    _contentController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final hasChanges = _hasUnsavedChanges;
    if (hasChanges != _lastHasUnsavedChanges) {
      setState(() {
        _lastHasUnsavedChanges = hasChanges;
      });
    }
  }

  bool get _hasUnsavedChanges {
    final currentTitle = _titleController.text.trim();
    final initialTitle = _initialTitle.trim();

    final currentContent = _contentController.text.trim();
    final initialContent = _initialContent.trim();

    final isTitleChanged = currentTitle != initialTitle;
    final isContentChanged = currentContent != initialContent;
    final isCategoryChanged = _selectedCategory != _initialCategory;
    final isFavoriteChanged = _isFavorite != _initialFavorite;

    return isTitleChanged ||
        isContentChanged ||
        isCategoryChanged ||
        isFavoriteChanged;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final notesProvider = context.read<NotesProvider>();

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    String? error;

    if (widget.isEditing) {
      final updatedNote = widget.note!.copyWith(
        title: title,
        content: content,
        category: _selectedCategory,
        isFavorite: _isFavorite,
      );
      error = await notesProvider.updateNote(updatedNote);
    } else {
      error = await notesProvider.createNote(
        title: title,
        content: content,
        category: _selectedCategory,
        isFavorite: _isFavorite,
      );
    }

    if (!mounted) return;

    if (error != null) {
      // Non-destructive failure: retain input fields, show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.errorOf(context),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleDelete() async {
    if (!widget.isEditing) return;

    final notesProvider = context.read<NotesProvider>();
    String? deleteError;

    final confirmed = await DeleteNoteDialog.show(
      context,
      noteTitle: widget.note!.title,
      onDelete: () async {
        deleteError = await notesProvider.deleteNote(widget.note!.id);
        return deleteError == null;
      },
    );

    if (!mounted) return;

    if (deleteError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(deleteError!),
          backgroundColor: AppColors.errorOf(context),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Note "${widget.note!.title.isNotEmpty ? widget.note!.title : 'Untitled'}" deleted',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final discardConfirmed = await ConfirmDialog.show(
      context,
      title: 'Discard Changes?',
      message: 'You have unsaved changes. Are you sure you want to discard them?',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep Editing',
      isDestructive: true,
    );

    return discardConfirmed;
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final isSaving = notesProvider.isSaving;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundOf(context),
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBackgroundOf(context),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () async {
              if (!_hasUnsavedChanges) {
                Navigator.of(context).pop();
                return;
              }
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            widget.isEditing ? 'Edit Note' : 'New Note',
            style: TextStyle(
              color: AppColors.textPrimaryOf(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            // Favorite Toggle
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: _isFavorite
                    ? AppColors.favorite
                    : (AppColors.isDark(context)
                        ? const Color(0xFF64748B)
                        : AppColors.favoriteInactive),
                size: 24,
              ),
              tooltip: _isFavorite ? 'Marked as favorite' : 'Mark as favorite',
              onPressed: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                  _lastHasUnsavedChanges = _hasUnsavedChanges;
                });
              },
            ),

            // Delete Note (Edit mode only)
            if (widget.isEditing)
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.errorOf(context),
                  size: 22,
                ),
                tooltip: 'Delete note',
                onPressed: isSaving ? null : _handleDelete,
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Selector Label & Pills
                        Text(
                          'Category',
                          style: TextStyle(
                            color: AppColors.textSecondaryOf(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: NoteCategory.values.map((cat) {
                            return CategoryBadge(
                              category: cat,
                              isSelected: _selectedCategory == cat,
                              onTap: () {
                                setState(() {
                                  _selectedCategory = cat;
                                  _lastHasUnsavedChanges = _hasUnsavedChanges;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Title Input
                        TextFormField(
                          controller: _titleController,
                          autofocus: !widget.isEditing,
                          maxLength: AppConstants.maxTitleLength,
                          validator: Validators.validateNoteTitle,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(
                            color: AppColors.textPrimaryOf(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Title',
                            hintText: 'e.g. Weekly Planning, Grocery List',
                            alignLabelWithHint: true,
                            counterStyle: TextStyle(
                              color: AppColors.textMutedOf(context),
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Content Input
                        TextFormField(
                          controller: _contentController,
                          maxLength: AppConstants.maxContentLength,
                          validator: Validators.validateNoteContent,
                          minLines: 8,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(
                            color: AppColors.textPrimaryOf(context),
                            fontSize: 14.5,
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Note Content',
                            hintText: 'Write down your thoughts, tasks, or notes...',
                            alignLabelWithHint: true,
                            counterStyle: TextStyle(
                              color: AppColors.textMutedOf(context),
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Save Action Button at the bottom
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: PrimaryButton(
                    label: widget.isEditing ? 'Save Changes' : 'Create Note',
                    isLoading: isSaving,
                    onPressed: _handleSave,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
