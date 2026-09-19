import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/note_model.dart';
import '../../../providers/notes_provider.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/confirm_dialog.dart';
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
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedCategory =
        widget.note?.category ?? widget.initialCategory ?? NoteCategory.personal;
    _isFavorite = widget.note?.isFavorite ?? false;

    _titleController.addListener(_markDirty);
    _contentController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
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

    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Note',
      message: 'Are you sure you want to delete "${widget.note!.title}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      final notesProvider = context.read<NotesProvider>();
      final error = await notesProvider.deleteNote(widget.note!.id);

      if (!mounted) return;

      if (error != null) {
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
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;

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
      canPop: !_isDirty,
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
                  _isDirty = true;
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
          bottom: false,
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
                                  _isDirty = true;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Title Input
                        TextFormField(
                          controller: _titleController,
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

                // Save Action Bar at the bottom
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurfaceOf(context),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.borderOf(context),
                        width: 1,
                      ),
                    ),
                  ),
                  child: PrimaryButton(
                    label: widget.isEditing ? 'Save Changes' : 'Create Note',
                    isLoading: isSaving,
                    icon: Icons.check_rounded,
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
